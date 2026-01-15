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
  print('Usage: dart aoc_2025_05.dart <flags> [arguments]');
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
      print('aoc_2025_05 version: $version');
      return;
    }
    if (results.flag('verbose')) {
      verbose = true;
    }

    // Act on the arguments provided.
    print('Positional arguments: ${results.rest}');

    var inventoryManagementSystem = InventoryManagementSystem();
    for (String currentArg in results.rest) {
      var freshIngredients = currentArg.split("-");
      var startingId = int.parse(freshIngredients[0]);
      var endId = int.parse(freshIngredients[1]);
      var range = Range(startingId, endId);
      inventoryManagementSystem.addRange(startingId, endId);
      print("freshIngredients added:  with id $range");
    }

    print(
      "count fresh ingredients: ${inventoryManagementSystem.countFreshIngredients()}",
    );

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

class Range {
  int inclusiveMin;
  int inclusiveMax;

  Range(int min, int max)
    : inclusiveMin = min < max ? min : max,
      inclusiveMax = max > min ? max : min;

  bool isInRange(int valueToTest) {
    return valueToTest >= inclusiveMin && valueToTest <= inclusiveMax;
  }

  bool isBelowRange(int valueToTest) {
    return valueToTest < inclusiveMin;
  }

  bool isAboveRange(int valueToTest) {
    return valueToTest > inclusiveMax;
  }

  int count() {
    return inclusiveMax - inclusiveMin + 1;
  }

  @override
  String toString() {
    return "Range($inclusiveMin, $inclusiveMax)";
  }
}

class Ingredient {
  int id;

  Ingredient(this.id);
  @override
  String toString() {
    return "Ingredient($id)";
  }
}

class InventoryManagementSystem {
  List<Range> freshIngredients = [];
  List<Ingredient> availableIngredients = [];

  int countFreshIngredients() {
    var freshIngredientCounter = 0;
    for (Range currenRange in freshIngredients) {
      freshIngredientCounter += currenRange.count();
    }
    return freshIngredientCounter;
  }

  void addRange(int minUnchecked, int maxUnchecked) {
    final min = minUnchecked < maxUnchecked ? minUnchecked : maxUnchecked;
    final max = maxUnchecked > minUnchecked ? maxUnchecked : minUnchecked;

    var newMin = min;
    var newMax = max;
    for (Range currentRange in freshIngredients) {
      if (isInRange(currentRange, newMin, newMax)) {
        // if current range is already available -> do nothing
        return;
      } else if (currentRange.isBelowRange(newMin) &&
          currentRange.isBelowRange(newMax)) {
        continue;
      } else if (currentRange.isAboveRange(newMin) &&
          currentRange.isAboveRange(newMax)) {
        continue;
      } else if (currentRange.isBelowRange(newMin) &&
          currentRange.isInRange(newMax)) {
        // min is out of range, but max is in range -> range is from finalMin -> range.min-1
        newMax = currentRange.inclusiveMin - 1;
      } else if (currentRange.isInRange(newMin) &&
          currentRange.isAboveRange(newMax)) {
        // min is in range, but max is out of range -> range is from range.max+1 - finalMax
        newMin = currentRange.inclusiveMax + 1;
      } else if (currentRange.isBelowRange(newMin) &&
          currentRange.isAboveRange(newMax)) {
        // min is below range && max is above range -> add to ranges, finalmin - range.min - 1 && range.max + 1 - finalMax
        addRange(newMin, currentRange.inclusiveMin - 1);
        addRange(currentRange.inclusiveMax + 1, newMax);
        return;
      }
    }
    freshIngredients.add(Range(newMin, newMax));
  }

  bool isInRange(Range currentRange, int min, int max) =>
      currentRange.isInRange(min) && currentRange.isInRange(max);

  @override
  String toString() {
    return "FreshIngredients: ${freshIngredients.map((i) => i.toString()).join(", ")}; availableIngredients: ${availableIngredients.map((i) => i.toString()).join(", ")}";
  }
}
