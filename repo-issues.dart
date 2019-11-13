import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'content-repos.dart';
import 'global.dart';

class RepoInfo {
  final String repoName;
  final int stars;
  final int openIssues;

  RepoInfo(this.repoName, this.stars, this.openIssues);
}

Future main(List<String> args) async {
  final repos = await retrieveTopStarredRepos();
  final repoMetadata = extractRepoMetadata(repos);
  printStarResults(repoMetadata);
}

void printStarResults(List<RepoInfo> repos, {int begin = 0, int end = 100}) {
  repos = repos.sublist(begin, min(end, repos.length - 1));

  // find the longest repo name; we'll use this for padding the text later
  int maxRepoNameLength = repos.fold(0, (t, e) => max(t, e.repoName.length));

  // sort repos by issue count
  repos.sort((a, b) => b.openIssues.compareTo(a.openIssues));

  print('  #  '
      '${"Repository".padRight(maxRepoNameLength)} '
      '${"Stars".padLeft(6)}'
      '${"Issues".padLeft(8)}');
  for (int i = 0; i < repos.length; i++) {
    final repo = repos[i];
    print('${(i + 1).toString().padLeft(3)}  '
        '${repo.repoName.padRight(maxRepoNameLength)} '
        '${repo.stars.toString().padLeft(6)}'
        '${repo.openIssues.toString().padLeft(8)}');
  }
}

List<RepoInfo> extractRepoMetadata(List repos) {
  var repoInfo = List<RepoInfo>();

  // filter archived and content-only repos
  repos.removeWhere((c) => c['archived']);
  repos.removeWhere((c) => contentRepos.contains(c['full_name']));

  for (final repo in repos) {
    repoInfo.add(RepoInfo(repo['full_name'], repo['stargazers_count'],
        repo['open_issues_count']));
  }

  return repoInfo;
}

Future<List> retrieveTopStarredRepos() async {
  var repos = List();
  for (int i = 1; i <= 3; i++) {
    var page = await retrieveStarsPage(i);

    repos.addAll(json.decode(page)['items']);
  }
  return repos;
}

Future<String> retrieveStarsPage(int pageNumber) async {
  http.Response response;

  try {
    response = await http.get(
        url +
            '?q=stars%3A>10000&sort=stars&order=desc&per_page=100&page=' +
            pageNumber.toString(),
        headers: {'User-Agent': userAgentHeader, 'Accept': acceptHeader});
  } catch (error) {
    var socketException = error as SocketException;
    if (socketException != null) {
      print(
          "Accessing the GitHub API failed with this error:\n${socketException.osError}");
      exit(1);
    }
  } finally {
    return response.body;
  }
}
