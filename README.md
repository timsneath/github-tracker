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
cd path/to/github-tracker
dart pub get
```

You can get help on the available commands by running:

```bash
dart <command>.dart --help
```

Optionally, you can compile each command to native code by running, for
instance:

```bash
dart compile exe repo-stars.dart -o repo-stars
```

### repo-stars

The following command gives an ordered list of the top 10 repos on GitHub:

```bash
$ dart repo-stars.dart -n 10
  #  Repository             Stars
  1  vuejs/vue             185850
  2  facebook/react        171582
  3  tensorflow/tensorflow 157503
  4  twbs/bootstrap        151884
  5  ohmyzsh/ohmyzsh       130632
  6  flutter/flutter       124736
  7  microsoft/vscode      118892
  8  torvalds/linux        115122
  9  ytdl-org/youtube-dl    97779
 10  d3/d3                  97601
```

By default, the command excludes "content repos" (those that are primarily
non-code, or where the code is primarily documentary rather than generative for
a specific app or library target). GitHub has many good examples of this, but
they're obviously a different kind of repo. Examples like:
[freeCodeCamp/freeCodeCamp](https://github.com/freeCodeCamp/freeCodeCamp),
[EbookFoundation/free-programming-books](https://github.com/EbookFoundation/free-programming-books),
[kamranahmedse/developer-roadmap](https://github.com/kamranahmedse/developer-roadmap)
and others. This list is manually curated.

You can include content repos to the list with the `--include-content-repos`
switch. For example:

```bash
$ dart repo-stars.dart --include-content-repos -n 5
  #  Repository                              Stars
  1  freeCodeCamp/freeCodeCamp              326292
  2  996icu/996.ICU                         257956
  3  EbookFoundation/free-programming-books 196945
  4  vuejs/vue                              185850
  5  jwasham/coding-interview-university    184430
 ```

If you'd prefer the data formatted as comma-separated-values, perhaps to append
to a file to graph trends over time, you can use the `--csv-output` switch:

```bash
$ dart repo-stars.dart --csv-output -n 5
2021/07/19 09:00:09,1,vuejs/vue,185850
2021/07/19 09:00:09,2,facebook/react,171583
2021/07/19 09:00:09,3,tensorflow/tensorflow,157503
2021/07/19 09:00:09,4,twbs/bootstrap,151884
2021/07/19 09:00:09,5,ohmyzsh/ohmyzsh,130632
```

### count-issues

`count-issues` returns the count of the number of issues given a repository
and Github query at the current time in a comma-delimited format. For example:

```bash
$ dart count-issues.dart --repo flutter/flutter --filter is:open,is:issue,label:framework
2021/07/19 09:00:27, 4002
```

## Acknowledgements

Thanks to [@csells](https://github.com/csells),
[@creativecreatorormaybenot](https://github.com/creativecreatorormaybenot) and
[@kf6gpe](https://github.com/kf6gpe) for various contributions. And thanks to
the amazing team of contributors behind the
[github](https://pub.dev/packages/github) package, who saved me a ton of work.
