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
  print('Usage: dart aoc_2025_06.dart <flags> [arguments]');
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
      print('aoc_2025_06 version: $version');
      return;
    }
    if (results.flag('verbose')) {
      verbose = true;
    }

    // Act on the arguments provided.
    print('Positional arguments: ${results.rest}');

    var fullArgs = results.rest.join(' ');

    //    print("fullargs: $fullArgs");

    var lines = fullArgs.split('.');

    //    print("lines: $lines");

    var numOfCalculations = lines.first.trim().split(' ').length;
    //    print("number of Calculatoins: $numOfCalculations");

    List<Calculation> calculations = List.generate(
      numOfCalculations,
      (i) => Calculation(),
    );

    for (var line in lines) {
      var entries = line.trim().split(' ');
      var firstVal = int.tryParse(entries.first);
      if (firstVal != null) {
        for (int i = 0; i < entries.length; i++) {
          calculations[i].numbers.add(int.parse(entries[i]));
        }
      } else {
        for (int i = 0; i < entries.length; i++) {
          calculations[i].operator = entries[i] == '+'
              ? Operator.addition
              : Operator.multiplication;
        }
      }
    }

    calculations.forEach(print);

    var result = calculations.fold(
      0,
      (previousValue, currentElement) =>
          previousValue + currentElement.calculate(),
    );

    print("result: $result");

    if (verbose) {
      print('[VERBOSE] All arguments: ${results.arguments}');
    }
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }
}

enum Operator { addition, multiplication }

class Calculation {
  List<int> numbers = [];
  Operator? operator;

  int calculate() {
    if (operator == Operator.addition) {
      return numbers.fold(
        0,
        (previousValue, element) => previousValue + element,
      );
    } else {
      return numbers.fold(
        1,
        (previousValue, element) => previousValue * element,
      );
    }
  }

  @override
  String toString() {
    return "calc: $operator $numbers";
  }
}
