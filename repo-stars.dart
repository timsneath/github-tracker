import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
const url = 'https://api.github.com/search/repositories';
const acceptHeader = 'application/vnd.github.v3+json';
const userAgentHeader = 'github-startracker';
const cachePath = 'cache.json';

ArgResults argResults;

// hardcoded for now. wonder if we can derive this list by looking at repos
// that are mostly Markdown or HTML?
final List contentRepos = [
  '996icu/996.ICU',
  'freeCodeCamp/freeCodeCamp',
  'EbookFoundation/free-programming-books',
  'sindresorhus/awesome',
  'getify/You-Dont-Know-JS',
  'airbnb/javascript',
  'github/gitignore',
  'jwasham/coding-interview-university',
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
  'Snailclimb/JavaGuide',
  'xingshaocheng/architect-awesome',
  'FreeCodeCampChina/freecodecamp.cn',
  'vinta/awesome-python',
  'avelino/awesome-go',
  'wasabeef/awesome-android-ui',
  'vsouza/awesome-ios',
  'enaqx/awesome-react',
  'awesomedata/awesome-public-datasets',
  'tiimgreen/github-cheat-sheet',
  'CyC2018/Interview-Notebook',
  'CyC2018/CS-Notes',
  'kdn251/interviews',
  'minimaxir/big-list-of-naughty-strings',
  'k88hudson/git-flight-rules',
  'Kickball/awesome-selfhosted',
  'jackfrued/Python-100-Days',
  'public-apis/public-apis',
  'scutan90/DeepLearning-500-questions',
  'MisterBooo/LeetCodeAnimation'
];

Future main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag('refresh',
        defaultsTo: false,
        abbr: 'r',
        help: 'Refresh data with API call to GitHub.\nBy default, a cache file '
            'is used if it exists.')
    ..addFlag('include-archived-repos',
        defaultsTo: false,
        abbr: 'a',
        negatable: true,
        help: 'Includes archived repos in the ranked list of top repos.\n'
            'Default is to exclude them.')
    ..addFlag('include-content-repos',
        defaultsTo: false,
        abbr: 'c',
        negatable: true,
        help: 'Includes content-only repos in the ranked list of top repos.\n'
            'Default is to exclude them.')
    ..addFlag('csv-output',
        defaultsTo: false,
        abbr: 'v',
        negatable: true,
        help: 'Outputs data in the following format: date,rank,repo,stars\n'
            'Useful for appending to a CSV file for graphing trends.\n'
            'Default is to export normally.')
    ..addFlag('help',
        defaultsTo: false,
        abbr: 'h',
        negatable: false,
        help: 'Displays this usage info.');

  argResults = parser.parse(args);
  if (argResults['help']) {
    print('Prints a ranked list of the top GitHub repos based on the specified '
        'options.\n\n'
        'Usage: dart repo-stars.dart [options]\n\n'
        'Common options:');
    print(parser.usage);
    return;
  }

  List repos;
  if (argResults['refresh'] || cacheMissingOrInvalidated(cachePath)) {
    repos = await retrieveTopStarredRepos();
    await writeStarredReposToCache(repos);
  } else {
    repos = loadStarredReposFromCache();
  }

  printStarResults(repos);
}

bool cacheMissingOrInvalidated(String cachePath) {
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

void printStarResults(List repos, {int begin = 0, int end = 100}) {
  // filter archived and content-only repos
  if (!argResults['include-archived-repos']) {
    repos.removeWhere((c) => c['archived']);
  }
  if (!argResults['include-content-repos']) {
    repos.removeWhere((c) => contentRepos.contains(c['full_name']));
  }

  repos = repos.sublist(begin, end);

  if (!argResults['csv-output']) {
    // find the longest repo name; we'll use this for padding the text later
    int maxRepoNameLength =
        repos.fold(0, (t, e) => max(t, e['full_name'].length));

    for (int i = 0; i < repos.length; i++) {
      final repo = repos[i];
      print('${(i + 1).toString().padLeft(3)}  '
          '${repo['full_name'].padRight(maxRepoNameLength)} '
          '${repo['stargazers_count'].toString().padLeft(6)}');
    }
  } else {
    var today = DateTime.now();
    var formatter = new DateFormat('yyyy/MM/dd HH:MM:SS');
    var date = formatter.format(today);
    for (int i = 0; i < repos.length; i++) {
      final repo = repos[i];
      print('$date,${i + 1},${repo['full_name']},${repo['stargazers_count']}');
    }
  }
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

List loadStarredReposFromCache() {
  final starsFile = File(cachePath);
  final stars = starsFile.readAsStringSync();
  return json.decode(stars);
}

writeStarredReposToCache(List repos) async {
  try {
    var starsFile = File(cachePath);
    var sink = starsFile.openWrite();
    sink.write(json.encode(repos));
    await sink.flush();
    await sink.close();
  } catch (e) {
    stderr.write('Error writing cache to disk.\n');
  }
}
