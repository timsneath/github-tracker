import 'dart:async';
import 'dart:math' show min, max;

import 'package:args/args.dart';

import 'lib/contentRepos.dart';
import 'lib/args.dart';
import 'lib/github.dart';
import 'lib/repoInfo.dart';

ArgResults argResults;

Future main(List<String> args) async {
  argResults = parser.parse(args);
  if (argResults['help']) {
    print('Prints a ranked list of the top GitHub repos based on the specified '
        'options.\n\n'
        'Usage: dart repo-stars.dart [options]\n\n'
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

  // find the longest repo name; we'll use this for padding the text later
  final int maxRepoNameLength =
      repos.fold(0, (t, e) => max(t, e.repoName.length));

  print('  #  '
      '${"Repository".padRight(maxRepoNameLength)} '
      '${"Stars".padLeft(6)}');
  for (int i = 0; i < repos.length; i++) {
    final repo = repos[i];
    print('${(i + 1).toString().padLeft(3)}  '
        '${repo.repoName.padRight(maxRepoNameLength)} '
        '${repo.stars.toString().padLeft(6)}');
  }
}
