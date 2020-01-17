import 'package:github/github.dart';
import 'package:intl/intl.dart';

import 'lib/args.dart';

/// Use this to count issues in a GitHub repo matching a specific query. For
/// instance:
///
/// https://github.com/flutter/flutter/issues?q=is%3Aopen+is%3Aissue+label%3A%22a%3A+annoyance%22+-label%3Aplugin
///
/// maps to:
///   `$ dart count-issues.dart --repo flutter/flutter --filter is:open,is:issue,label:\"a:\ annoyance\",-label:plugin`
/// or, equivalently:
///   `$ dart count-issues.dart --repo flutter/flutter --filter is:open --filter is:issue --filter label:\"a:\ annoyance\" --filter -label:plugin`
///
/// (Note the escaping of the quote and space in UNIX-style shell environments.)
Future<void> main(List<String> args) async {
  final argResults = issueParser.parse(args);
  if (argResults['help']) {
    print('Prints the number of responses available for the given Github label '
        'query.\n\n'
        'Usage: dart count-issues.dart [options]\n\n'
        'Common options:');
    print(issueParser.usage);
    return;
  }

  final repoName = argResults['repo'];
  final filters = argResults['filter'];

  final gitHub = GitHub();

  final fullQuery = 'repo:$repoName ${filters.join(" ")}';
  final issues = gitHub.search.issues(fullQuery);
  final issueCount = await issues.length;

  final date = DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now());
  print('$date, $issueCount');

  gitHub.dispose();
}
