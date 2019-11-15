import 'package:args/args.dart';

// Global parser options
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
      help: 'Includes archived repos in the ranked list of repos.\n'
          'Default is to exclude them.')
  ..addFlag('include-content-repos',
      defaultsTo: false,
      abbr: 'c',
      negatable: true,
      help: 'Includes content-only repos in the ranked list of repos.\n'
          'Default is to exclude them.')
  ..addFlag('help',
      defaultsTo: false,
      abbr: 'h',
      negatable: false,
      help: 'Displays this usage info.');
