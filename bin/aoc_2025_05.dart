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
    var processFreshList = true;
    for (String currentArg in results.rest) {
      if (currentArg == "+") {
        processFreshList = false;
        continue;
      }

      if (processFreshList) {
        var freshIngredients = currentArg.split("-");
        var startingId = int.parse(freshIngredients[0]);
        var endId = int.parse(freshIngredients[1]);
        var range = Range(startingId, endId);
        inventoryManagementSystem.freshIngredients.add(range);
        print("freshIngredients added:  with id $range");
      } else {
        inventoryManagementSystem.availableIngredients.add(
          Ingredient(int.parse(currentArg)),
        );
        print("available Ingredient added with id ${int.parse(currentArg)}");
      }
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
  Ingredient inclusiveMin;
  Ingredient inclusiveMax;

  Range(int min, int max)
    : inclusiveMin = Ingredient(min < max ? min : max),
      inclusiveMax = Ingredient(max > min ? max : min);

  bool isInRange(Ingredient i) {
    return i.id >= inclusiveMin.id && i.id <= inclusiveMax.id;
  }

  @override
  String toString() {
    return "Range(${inclusiveMin.id}, ${inclusiveMax.id})";
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

  bool isFresh(Ingredient ingredientToCheckForFreshness) {
    return freshIngredients.any(
      (freshIngredient) =>
          freshIngredient.isInRange(ingredientToCheckForFreshness),
    );
  }

  int countFreshIngredients() {
    var freshIngredientCounter = 0;
    for (Ingredient currentIngredient in availableIngredients) {
      if (isFresh(currentIngredient)) {
        freshIngredientCounter++;
      }
    }
    return freshIngredientCounter;
  }

  @override
  String toString() {
    return "FreshIngredients: ${freshIngredients.map((i) => i.toString()).join(", ")}; availableIngredients: ${availableIngredients.map((i) => i.toString()).join(", ")}";
  }
}
