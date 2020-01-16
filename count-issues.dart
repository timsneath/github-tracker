import 'dart:async';

import 'package:args/args.dart';
import 'package:intl/intl.dart';

import 'lib/args.dart';
import 'lib/github.dart';

ArgResults argResults;

/*
  An example query
is%3Aopen+is%3Aissue+-label%3Aframework+-label%3Aengine+-label%3Atool+-label%3Aplugin+-label%3Apackage+-label%3A%22will+need+additional+triage%22+-label%3A%22%E2%98%B8+platform-web%22+-label%3A%22a%3A+desktop%22+-label%3A%22team%3A+infra%22+-label%3A%22a%3A+existing-apps%22+sort%3Aupdated-asc+-label%3A%22waiting+for+customer+response%22+

  An example invocation

dart count-query-responses.dart -q 'is%3Aopen+is%3Aissue+-label%3Aframework+-label%3Aengine+-label%3Atool+-label%3Aplugin+-label%3Apackage+-label%3A%22will+need+additional+triage%22+-label%3A%22%E2%98%B8+platform-web%22+-label%3A%22a%3A+desktop%22+-label%3A%22team%3A+infra%22+-label%3A%22a%3A+existing-apps%22+sort%3Aupdated-asc+-label%3A%22waiting+for+customer+response%22+' --repo 'flutter/flutter'

*/

Future main(List<String> args) async {
  argResults = issueParser.parse(args);
  if (argResults['help']) {
    print('Prints the number of responses available for the given Github label '
        'query.\n\n'
        'Usage: dart count-query-responses [options]\n\n'
        'Common options:');
    print(issueParser.usage);
    return;
  }

  final url = argResults['query'];
  final repo = argResults['repo'];

  final gh = GitHub();
  int count = await gh.retrieveIssuesCount(url, repo);

  final today = DateTime.now();
  final formatter = new DateFormat('yyyy/MM/dd HH:MM:ss');
  final date = formatter.format(today);
  print('${date}, ${count}');
}
