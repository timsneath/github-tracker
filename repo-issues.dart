import 'dart:async';
import 'dart:math' show min, max;

import 'package:args/args.dart';
import 'package:intl/intl.dart';

import 'lib/contentRepos.dart';
import 'lib/args.dart';
import 'lib/github.dart';
import 'lib/repoInfo.dart';

ArgResults argResults;

Future main(List<String> args) async {
  final parser = repoParser
    ..addFlag('csv-output',
        defaultsTo: false,
        abbr: 'v',
        negatable: true,
        help:
            'Outputs data in the following format: date,rank,repo,issues,stars.\n'
            'Useful for appending to a CSV file for graphing trends.\n'
            'Default is to export normally.');
  argResults = parser.parse(args);
  if (argResults['help']) {
    print('Prints a ranked list of the GitHub repos with the highest number of '
        'issues, based on the specified options.\n\n'
        'Usage: dart repo-issues.dart [options]\n\n'
        'Common options:');
    print(parser.usage);
    return;
  }

  final gh = GitHub();
  if (argResults['refresh'] || gh.isCacheMissingOrInvalidated) {
    await gh.retrieveRepos(300);
  } else {
    await gh.loadCache();
  }

  printStarResults(gh.repos);
}

void printStarResults(List<RepoInfo> repos, {int begin = 0, int end = 100}) {
  // filter archived and content-only repos
  if (!argResults['include-archived-repos']) {
    repos.removeWhere((c) => c.isArchived);
  }

  if (!argResults['include-content-repos']) {
    repos.removeWhere((c) => contentRepos.contains(c.repoName));
  }

  repos = repos.sublist(begin, min(end, repos.length - 1));

  int maxResults = int.tryParse(argResults['results']);
  if (maxResults == null) maxResults = 100;

  // sort repos by issue count
  repos.sort((a, b) => b.openIssues.compareTo(a.openIssues));

  if (!argResults['csv-output']) {
    // find the longest repo name; we'll use this for padding the text later
    int maxRepoNameLength = repos.fold(0, (t, e) => max(t, e.repoName.length));

    if (argResults['include-header']) {
      print('  #  '
          '${"Repository".padRight(maxRepoNameLength)} '
          '${"Stars".padLeft(6)}'
          '${"Issues".padLeft(8)}');
    }

    for (int i = 0; i < min(repos.length, maxResults); i++) {
      final repo = repos[i];
      print('${(i + 1).toString().padLeft(3)}  '
          '${repo.repoName.padRight(maxRepoNameLength)} '
          '${repo.stars.toString().padLeft(6)}'
          '${repo.openIssues.toString().padLeft(8)}');
    }
  } else {
    final today = DateTime.now();
    final formatter = DateFormat('yyyy/MM/dd HH:mm:ss');
    final date = formatter.format(today);
    for (int i = 0; i < min(repos.length, maxResults); i++) {
      final repo = repos[i];
      print('$date,${i + 1},${repo.repoName},${repo.openIssues},${repo.stars}');
    }
  }
}
