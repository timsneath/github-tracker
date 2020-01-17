# GitHub Repo Tracker

[![Build Status](https://travis-ci.org/timsneath/github-tracker.svg?branch=master)](https://travis-ci.org/timsneath/github-tracker)

Grabs useful information from GitHub. 

| Command      | Description                                         |
|--------------|-----------------------------------------------------|
| repo-stars   | Provides an ordered list of the top repos on GitHub |
| repo-issues  | Provides an ordered list of repos by issues         |
| count-issues | Counts the number of issues matching a query        |

## Usage

Make sure you have the Dart SDK installed (<https://dart.dev>).

Also make sure to grab the dependencies first:

```bash
$ cd path/to/github-tracker
$ pub get
```

You can get help on the available commands by running:

```bash
$ dart <command>.dart --help
```

Optionally, you can compile each command to native code by running, for
instance:

```bash
$ dart2native repo-stars.dart -o repo-stars
```

### repo-stars

The following command gives an ordered list of the top 10 repos on GitHub:

```bash
$ dart repo-stars.dart -n 10
  #  Repository                             Stars
  1  vuejs/vue                             152178
  2  facebook/react                        139422
  3  tensorflow/tensorflow                 137333
  4  twbs/bootstrap                        136832
  5  robbyrussell/oh-my-zsh                 98642
  6  d3/d3                                  88548
  7  microsoft/vscode                       86616
  8  torvalds/linux                         82719
  9  facebook/react-native                  82602
 10  flutter/flutter                        79222
```

By default, the command excludes non-software repos (i.e. those which are
primarily content). This includes
[freeCodeCamp/freeCodeCamp](https://github.com/freeCodeCamp/freeCodeCamp),
[EbookFoundation/free-programming-books](https://github.com/EbookFoundation/free-programming-books),
[kamranahmedse/developer-roadmap](https://github.com/kamranahmedse/developer-roadmap)
and others. This list is
manually curated. 

You can add content repos with the `--include-content-repos` switch. For
example:

```bash
$ dart repo-stars.dart --include-content-repos -n 5
  #  Repository                                    Stars
  1  freeCodeCamp/freeCodeCamp                    306229
  2  996icu/996.ICU                               247778
  3  vuejs/vue                                    152178
  4  facebook/react                               139422
  5  tensorflow/tensorflow                        137333
 ```
 
If you'd prefer the data formatted as comma-separated-values, perhaps to append
to a file to graph trends over time, you can use the `--csv-output` switch:

```bash
$ dart repo-stars.dart --csv-output -n 5
2019/11/14 20:11:31,1,vuejs/vue,152178
2019/11/14 20:11:31,2,facebook/react,139422
2019/11/14 20:11:31,3,tensorflow/tensorflow,137333
2019/11/14 20:11:31,4,twbs/bootstrap,136832
2019/11/14 20:11:31,5,robbyrussell/oh-my-zsh,98642
```

### count-issues

`count-issues` returns the count of the number of issues given a repository
and Github query at the current time in a comma-delimited format. For example:

```bash
$ dart count-issues.dart --repo 'flutter/flutter' \
--query 'is%3Aopen+is%3Aissue+label%3Aframework'
2020/01/15 12:01:06,3124
```

## Acknowledgements

Thanks to [@csells](https://github.com/csells) and
[@kf6gpe](https://github.com/kf6gpe) for contributions. And thanks to
the amazing team of contributors behind the 
[github](https://pub.dev/packages/github) package, who saved me
a ton of work. 
