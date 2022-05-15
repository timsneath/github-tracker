import 'dart:math' show min, max;

import 'package:github/github.dart';
import 'package:intl/intl.dart';

import 'lib/args.dart';
import 'lib/content_repos.dart';

Future<void> main(List<String> args) async {
  final parser = repoParser
    ..addFlag('csv-output',
        defaultsTo: false,
        abbr: 'v',
        negatable: true,
        help: 'Outputs data in the following format: date,rank,repo,stars\n'
            'Useful for appending to a CSV file for graphing trends.\n'
            'Default is to export normally.');

  final argResults = parser.parse(args);
  if (argResults['help'] == true) {
    print('Prints a ranked list of the top GitHub repos based on the specified '
        'options.\n\n'
        'Usage: dart repo-stars.dart [options]\n\n'
        'Common options:');
    print(parser.usage);
    return;
  }

  var maxResults = int.tryParse(argResults['results'] as String);
  maxResults ??= 30;

  final gitHub = GitHub();
  final query = 'stars:>10000';

  // GitHub pagination returns 30 results per page by default, per their API.
  // We 'guess' that no more than half of the repos returned will be filtered
  // out. If that guess is incorrect, then we may return less than the
  // requested number of results.
  var repos = gitHub.search
      .repositories(query, sort: 'stars', pages: (maxResults * 2 / 30).ceil());

  // filter archived and content-only repos
  if (argResults['include-archived-repos'] == false) {
    repos = repos.where((repo) => !repo.archived);
  }

  if (argResults['include-content-repos'] == false) {
    repos = repos.where((repo) => !contentRepos.contains(repo.fullName));
  }

  final reposList = await repos.take(maxResults).toList();

  if (argResults['csv-output'] == false) {
    // find the longest repo name; we'll use this for padding the text later
    final maxRepoNameLength = reposList.fold(
        0, (int t, Repository e) => max<int>(t, e.fullName.length));

    if (argResults['include-header'] == true) {
      print('  #  '
          '${"Repository".padRight(maxRepoNameLength)} '
          '${"Stars".padLeft(6)}');
    }
    for (var i = 0; i < min(reposList.length, maxResults); i++) {
      final repo = reposList[i];
      print('${(i + 1).toString().padLeft(3)}  '
          '${repo.fullName.padRight(maxRepoNameLength)} '
          '${repo.stargazersCount.toString().padLeft(6)}');
    }
  } else {
    final date = DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now());

    for (var i = 0; i < min(reposList.length, maxResults); i++) {
      final repo = reposList[i];
      print('$date,${i + 1},${repo.fullName},${repo.stargazersCount}');
    }
  }

  gitHub.dispose();
}
