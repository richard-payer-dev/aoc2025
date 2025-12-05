import 'package:args/args.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag('version', negatable: false, help: 'Print the tool version.');
}

void printUsage(ArgParser argParser) {
  print('Usage: dart aoc_2025_02.dart <flags> [arguments]');
  print(argParser.usage);
}

void main(List<String> arguments) {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    bool verbose = false;

    // Process the parsed arguments.
    if (results.flag('help')) {
      printUsage(argParser);
      return;
    }
    if (results.flag('version')) {
      print('aoc_2025_02 version: $version');
      return;
    }
    if (results.flag('verbose')) {
      verbose = true;
    }

    // Act on the arguments provided.
    print('Positional arguments: ${results.rest}');

    if (verbose) {
      print('[VERBOSE] All arguments: ${results.arguments}');
    }

    var ranges = inputToRanges(results.rest[0]);
    var invalidProductIds = findAllInvalidProdcutIds(ranges);
    int sum = 0;
    for (int invalidProductId in invalidProductIds) {
      sum += invalidProductId;
    }
    print("Sum: $sum");
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }
}

List<int> findAllInvalidProdcutIds(List<Range> ranges) {
  RegExp regExp = RegExp(r'^(.+?)\1+$');

  List<int> invalidProductIds = [];
  for (Range currentRange in ranges) {
    for (int i = currentRange.bottom; i <= currentRange.top; i++) {
      var productIdStr = i.toString();

      /*
      // solution for 2_1
      if (productIdStr.length % 2 == 0) {
        var firstHalf = productIdStr.substring(
          0,
          (productIdStr.length / 2).round(),
        );
        var secondHalf = productIdStr.substring(
          (productIdStr.length / 2).round(),
        );

        if (firstHalf == secondHalf) {
          invalidProductIds.add(i);
        }
      }
      */

      // solution for 2_2
      if (regExp.hasMatch(productIdStr)) {
        invalidProductIds.add(i);
      }
    }
  }
  return invalidProductIds;
}

List<Range> inputToRanges(String input) {
  List<Range> ranges = [];
  var rangeStrs = input.split(",");
  for (String currentRange in rangeStrs) {
    var bottomAndTop = currentRange.split("-");
    var bottom = int.parse(bottomAndTop[0]);
    var top = int.parse(bottomAndTop[1]);
    ranges.add(Range(bottom, top));
  }
  return ranges;
}

class Range {
  int bottom;
  int top;
  Range(this.bottom, this.top);

  Map<String, dynamic> toJson() => {'bottom': bottom, 'top': top};
}
