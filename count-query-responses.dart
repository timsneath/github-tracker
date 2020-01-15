import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
const acceptHeader = 'application/vnd.github.v3+json';
const userAgentHeader = 'count-query-responses';
const cachePath = 'cache.json';
const searchUrl = 'https://api.github.com/search/issues?q=';

ArgResults argResults;

/*
  An example query
is%3Aopen+is%3Aissue+-label%3Aframework+-label%3Aengine+-label%3Atool+-label%3Aplugin+-label%3Apackage+-label%3A%22will+need+additional+triage%22+-label%3A%22%E2%98%B8+platform-web%22+-label%3A%22a%3A+desktop%22+-label%3A%22team%3A+infra%22+-label%3A%22a%3A+existing-apps%22+sort%3Aupdated-asc+-label%3A%22waiting+for+customer+response%22+

  An example invocation

dart count-query-responses.dart -q 'is%3Aopen+is%3Aissue+-label%3Aframework+-label%3Aengine+-label%3Atool+-label%3Aplugin+-label%3Apackage+-label%3A%22will+need+additional+triage%22+-label%3A%22%E2%98%B8+platform-web%22+-label%3A%22a%3A+desktop%22+-label%3A%22team%3A+infra%22+-label%3A%22a%3A+existing-apps%22+sort%3Aupdated-asc+-label%3A%22waiting+for+customer+response%22+' --repo 'flutter/flutter'

*/


Future main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('query', abbr: 'q', )
    ..addOption('repo', abbr: 'r')
    ..addFlag('help', abbr: 'h', negatable: false);


  argResults = parser.parse(args);
  if (argResults['help']) {
    print('Prints the number of responses available for the given Github label query. '
        'Usage: dart count-query-responses [options]\n\n'
        'Common options:');
    print(parser.usage);
    return;
  }
  String url = argResults['query'];
  String repo = argResults['repo'];
  int count = await retrieveCount(url, repo);

  var today = DateTime.now();
  var formatter = new DateFormat('yyyy/MM/dd HH:MM:ss');
  var date = formatter.format(today);
  print('${date},${count}');
}


Future<int> retrieveCount(String query, String repo) async {
  http.Response response;

  String url = searchUrl + 
        'repo%3A${repo}+' +
        query;
  try {
    response = await http.get(url,
        headers: {'User-Agent': userAgentHeader, 'Accept': acceptHeader});
  } catch (error) {
    var socketException = error as SocketException;
    if (socketException != null) {
      print(
          "Accessing the Github API failed with this error:\n${socketException.osError}");
      exit(1);
    }
  } finally {
    int count = json.decode(response.body)['total_count'];
    return count;
  }
  return 0;
}

