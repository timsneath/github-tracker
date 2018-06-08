import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';
import 'package:http/http.dart' as http;

const url = 'https://api.github.com/search/repositories';
const acceptHeader = 'application/vnd.github.v3+json';
const userAgentHeader = 'github-startracker';
const cachePath = 'cache.json';

final List contentRepos = [
  'freeCodeCamp/freeCodeCamp',
  'EbookFoundation/free-programming-books',
  'sindresorhus/awesome',
  'getify/You-Dont-Know-JS',
  'airbnb/javascript',
  'github/gitignore',
  'jwasham/coding-interview-university',
  'vinta/awesome-python',
  'kamranahmedse/developer-roadmap',
  'h5bp/html5-boilerplate',
  'toddmotto/public-apis',
  'resume/resume.github.com',
  'nvbn/thefuck',
  'h5bp/Front-end-Developer-Interview-Questions',
  'jlevy/the-art-of-command-line',
  'google/material-design-icons',
  'mtdvio/every-programmer-should-know',
  'justjavac/free-programming-books-zh_CN',
  'vuejs/awesome-vue',
  'josephmisiti/awesome-machine-learning',
  'ossu/computer-science',
  'NARKOZ/hacker-scripts',
  'papers-we-love/papers-we-love',
  'danistefanovic/build-your-own-x',
  'thedaviddias/Front-End-Checklist',
  'Trinea/android-open-project',
  'donnemartin/system-design-primer',
  'FreeCodeCampChina/freecodecamp.cn',
  'vsouza/awesome-ios',
  'enaqx/awesome-react',
  'awesomedata/awesome-public-datasets',
  'tiimgreen/github-cheat-sheet'
];

Future main(List<String> args) async {
  final parser = new ArgParser();
  parser.addFlag('refresh',
      defaultsTo: false,
      abbr: 'r',
      help: 'Refresh data with API call to GitHub. By default, a cache file is '
          'used if it exists.');
  parser.addFlag('help',
      defaultsTo: false, abbr: 'h', negatable: false, help: 'Displays help');

  final argResults = parser.parse(args);
  if (argResults['help']) {
    print(parser.usage);
    return;
  }

  List repos;
  if (argResults['refresh'] ||
      FileSystemEntity.typeSync(cachePath) == FileSystemEntityType.notFound) {
    repos = await retrieveTop300StarredRepos();
    writeStarsPage(repos);
  } else {
    repos = loadStarsPage();
  }

  printStarResults(repos.sublist(0, 100));
}

void printStarResults(List repos) {
  // filter archived and content-only repos
  repos.removeWhere((c) => c['archived']);
  repos.removeWhere((c) => contentRepos.contains(c['full_name']));

  // find the longest repo name; we'll use this for padding the text later
  num maxRepoNameLength =
      repos.fold(0, (t, e) => max(t, e['full_name'].length));

  for (var i = 0; i < repos.length; i++) {
    final repo = repos[i];
    print('${(i+1).toString().padLeft(3)}  '
        '${repo['full_name'].padRight(maxRepoNameLength)} '
        '${repo['stargazers_count'].toString().padLeft(6)}');
  }
}

Future<List> retrieveTop300StarredRepos() async {
  var repos = new List();
  for (num i = 1; i <= 3; i++) {
    var page = await retrieveStarsPage(i);
    repos.addAll(json.decode(page)['items']);
  }
  return repos;
}

Future<String> retrieveStarsPage(int page) async {
  final response = await http.get(
      url +
          '?q=stars%3A>20000&sort=stars&order=desc&per_page=100&page=' +
          page.toString(),
      headers: {'User-Agent': userAgentHeader, 'Accept': acceptHeader});

  return response.body;
}

List loadStarsPage() {
  final starsFile = new File(cachePath);
  final stars = starsFile.readAsStringSync();
  return json.decode(stars);
}

writeStarsPage(List repos) async {
  var starsFile = new File(cachePath);
  var sink = starsFile.openWrite();
  sink.write(json.encode(repos));
  await sink.flush();
  await sink.close();
}
