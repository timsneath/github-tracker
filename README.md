# GitHub Repo Tracker

[![Build Status](https://travis-ci.org/timsneath/github-tracker.svg?branch=master)](https://travis-ci.org/timsneath/github-tracker)

Grabs useful information from GitHub. At present, this only has one command
available (but I'll probably add more over time).

| Command    | Description                                         |
|------------|-----------------------------------------------------|
| repo-stars | Provides an ordered list of the top repos on GitHub |

## Usage

Make sure you have the Dart SDK installed (<https://dartlang.org>).

Also make sure to grab the dependencies first:

```bash
$ cd path/to/github-tracker
$ pub get
```

The following command gives an ordered list of the top 100 repos on GitHub:

```bash
$ dart repo-stars.dart
  1  twbs/bootstrap                     125174
  2  tensorflow/tensorflow              102100
  3  facebook/react                      97742
  4  vuejs/vue                           96932
  5  d3/d3                               76338
  6  robbyrussell/oh-my-zsh              71507
  7  facebook/react-native               64757
  8  electron/electron                   61007
  9  torvalds/linux                      59445
 10  angular/angular.js                  58579
 11  FortAwesome/Font-Awesome            56580
 12  Microsoft/vscode                    52300
 ...
 90  google/protobuf                     26632
 91  gohugoio/hugo                       26193
 92  zeit/next.js                        26051
 93  flutter/flutter                     26050
 94  TryGhost/Ghost                      25882
 95  gogs/gogs                           25514
 96  spring-projects/spring-boot         25382
 97  shadowsocks/shadowsocks             25283
 98  opencv/opencv                       25260
 99  discourse/discourse                 25204
100  prettier/prettier                   25041
```

The command above also stores more detailed output from GitHub in a file
`cache.json`. Repeated invocations over the command use the cache to minimize
hitting the GitHub rate limit, although you can refresh the cache by using the
`--refresh` option, for example:

```bash
$ dart repo-stars.dart --refresh
```

By default, the command excludes non-software repos (i.e. those which are primarily content). This includes https://github.com/freeCodeCamp/freeCodeCamp, https://github.com/EbookFoundation/free-programming-books,  https://github.com/kamranahmedse/developer-roadmap and others. This list is manually curated. 

You can add content repos with the `--include-content-repos` switch. For example:

```bash
$ dart repo-stars.dart --include-content-repos | head -n 5
  1  freeCodeCamp/freeCodeCamp                    296791
  2  twbs/bootstrap                               129787
  3  vuejs/vue                                    123900
  4  facebook/react                               118973
  5  tensorflow/tensorflow                        117898
 ```

If you'd prefer the data formatted as comma-separated-values, perhaps to append to a file to graph trends over time, you can use the `--csv-output` switch, which outputs the data in the following order: date,rank,repo,stars. For example:

```bash
$ dart repo-stars.dart --csv-output | head -n 5
2019/10/17,1,vuejs/vue,150354
2019/10/17,2,facebook/react,137883
2019/10/17,3,twbs/bootstrap,136335
2019/10/17,4,tensorflow/tensorflow,136068
2019/10/17,5,robbyrussell/oh-my-zsh,96809
```

You can get further usage help by running:

```bash
$ dart repo-stars.dart --help
```

## Known Issues

- The command uses a brute force of getting the top 300 repos with > 10,000
  stars and then filtering. We should get a count and grab the appropriate
  quantity of paginated content to fill the JSON cache as appropriate.
