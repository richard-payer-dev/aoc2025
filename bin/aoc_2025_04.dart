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
  print('Usage: dart aoc_2025_04.dart <flags> [arguments]');
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
      print('aoc_2025_04 version: $version');
      return;
    }
    if (results.flag('verbose')) {
      verbose = true;
    }

    // Act on the arguments provided.
    print('Positional arguments: ${results.rest}');

    var x = results.rest.length;
    var y = results.rest.first.length;

    Grid grid = initializeGrid(x, y, results);

    for (List<Position> currentRow in grid.positions) {
      print(currentRow);
    }

    var countOfRollsOfPaperThatCanBeLifted = 0;
    List<Position> rollsOfPaperThatCanBeLifted = [];
    do {
      rollsOfPaperThatCanBeLifted = findRollsThatCanBeLifted(grid);
      countOfRollsOfPaperThatCanBeLifted += rollsOfPaperThatCanBeLifted.length;
      print(
        "total rolls that can be lifted in current step: ${rollsOfPaperThatCanBeLifted.length}",
      );

      for (Position toRemove in rollsOfPaperThatCanBeLifted) {
        grid.positions[toRemove.x][toRemove.y].isNotEmpty = false;
      }
    } while (rollsOfPaperThatCanBeLifted.isNotEmpty);

    print(
      "total rolls that can be lifted: $countOfRollsOfPaperThatCanBeLifted",
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

List<Position> findRollsThatCanBeLifted(Grid grid) {
  List<Position> rollsCanBeLifted = [];
  // step trough grid positions
  for (int i = 0; i < grid.positions.length; i++) {
    for (int j = 0; j < grid.positions[0].length; j++) {
      if (!grid.positions[i][j].isNotEmpty) {
        continue;
      }
      var rollsForCurrentPosition = 0;
      // step through neighbours of current grid position
      for (
        int neighbourVerticalIndex = -1;
        neighbourVerticalIndex <= 1;
        neighbourVerticalIndex++
      ) {
        for (
          int neighbourHorizontalIndex = -1;
          neighbourHorizontalIndex <= 1;
          neighbourHorizontalIndex++
        ) {
          if (neighbourHorizontalIndex == 0 && neighbourVerticalIndex == 0) {
            continue;
          }

          try {
            var currentPosition =
                grid.positions[i + neighbourVerticalIndex][j +
                    neighbourHorizontalIndex];
            if (currentPosition.isNotEmpty) {
              rollsForCurrentPosition++;
            }
          } on RangeError {
            // do nothing
          }
        }
      }
      if (rollsForCurrentPosition < 4) {
        rollsCanBeLifted.add(grid.positions[i][j]);
      }
    }
  }
  return rollsCanBeLifted;
}

Grid initializeGrid(int x, int y, ArgResults results) {
  var grid = Grid(x, y);
  int i = 0;
  for (String currentArgument in results.rest) {
    int j = 0;
    for (String currentPosition in currentArgument.split('')) {
      if (currentPosition == '@') {
        grid.positions[i].add(Position(i, j, true));
      } else {
        grid.positions[i].add(Position(i, j, false));
      }
      j++;
    }
    i++;
  }

  grid.initialized = true;
  return grid;
}

class Position {
  int x;
  int y;
  bool isNotEmpty;

  Position(this.x, this.y, this.isNotEmpty);

  @override
  toString() => "[($x/$y)${isNotEmpty ? "@" : "."}]";
}

class Grid {
  List<List<Position>> positions;
  bool initialized = false;

  Grid(int x, int y)
    : positions = List.generate(
        x,
        (_) => List.generate(0, (_) => Position(x, y, false), growable: true),
        growable: true,
      );
}
