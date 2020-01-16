import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'repoInfo.dart';

const url = 'https://api.github.com/search/';
const acceptHeader = 'application/vnd.github.v3+json';
const userAgentHeader = 'github-startracker';
const cachePath = 'cache.json';

class GitHub {
  var repos = List<RepoInfo>();

  /// Retrieve metadata about the number of issues, given a specific repo and
  /// query string.
  Future<int> retrieveIssuesCount(String query, String repo) async {
    http.Response response;

    try {
      response = await http.get(url + 'issues?q=repo%3A$repo+$query',
          headers: {'User-Agent': userAgentHeader, 'Accept': acceptHeader});
    } on SocketException catch (socketException) {
      print(
          "Accessing the GitHub API failed with this error:\n  ${socketException.osError}");
      exit(1);
    } finally {
      return json.decode(response.body)['total_count'];
    }
  }

  /// Retrieves metadata about the top _n_ repos from GitHub.
  ///
  /// Because the API enforces pagination of large result sets, the actual
  /// returned number of results may be different.
  void retrieveRepos(int desiredRepoCount) async {
    for (int pageNumber = 1;
        pageNumber <= (desiredRepoCount / 100).ceil();
        pageNumber++) {
      var pageRawResponse = await retrieveStarsPage(pageNumber);

      final List<dynamic> jsonResponse = json.decode(pageRawResponse)['items'];

      for (final repo in jsonResponse) {
        repos.add(RepoInfo.fromJson(repo));
      }
    }

    await writeCache(repos);
  }

  /// Retrieves a specific page from the given query.
  Future<String> retrieveStarsPage(int pageNumber) async {
    http.Response response;

    try {
      response = await http.get(
          url +
              'repositories?q=stars%3A>10000&sort=stars&order=desc&per_page=100&page=' +
              pageNumber.toString(),
          headers: {'User-Agent': userAgentHeader, 'Accept': acceptHeader});
    } on SocketException catch (socketException) {
      print(
          "Accessing the GitHub API failed with this error:\n  ${socketException.osError}");
      exit(1);
    } finally {
      return response.body;
    }
  }

  /// Writes a cache of the JSON results to avoid being rate-limited by GitHub
  writeCache(List<RepoInfo> repos) async {
    try {
      final starsFile = File(cachePath);
      final sink = starsFile.openWrite();
      sink.write(json.encode(repos));

      await sink.flush();
      await sink.close();
    } catch (e) {
      stderr.write('Error writing cache to disk.\n');
    }
  }

  /// Loads a saved cache written by [writeCache]
  loadCache() async {
    final starsFile = File(cachePath);
    final stars = await starsFile.readAsString();
    final decodedRepos = json.decode(stars);
    for (final repo in decodedRepos) {
      repos.add(RepoInfo.fromJson(repo));
    }
  }

  /// Checks whether the cached GitHub results are still valid
  bool get isCacheMissingOrInvalidated {
    if (FileSystemEntity.typeSync(cachePath) != FileSystemEntityType.file) {
      return true;
    }

    final cacheLastModifiedDateTime = File(cachePath).lastModifiedSync();
    if (DateTime.now().difference(cacheLastModifiedDateTime).inHours > 24) {
      return true;
    } else {
      return false;
    }
  }
}

main(List<String> args) async {
  final gh = GitHub();
  await gh.retrieveRepos(20);
  print(gh.repos.length);
  print(gh.repos[0]);
}
