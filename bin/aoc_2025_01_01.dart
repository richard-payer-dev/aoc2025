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
  print('Usage: dart aoc_2025_01_01.dart <flags> [arguments]');
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
      print('aoc_2025_01_01 version: $version');
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

    var rotations = results.rest.map(
      (currentArgument) => mapRotation(currentArgument),
    );
    var numberOfZerosOccurred = findZeroOccurences(rotations.toList());

    print("Zeros met after the rotations was $numberOfZerosOccurred");
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }
}

int findZeroOccurences(List<Rotation> rotations) {
  int timesZeroMet = 0;
  var rotationWheel = createRotationWheel();
  var currentPosition = rotationWheel[50];

  for (Rotation currentRotation in rotations) {
    //    print("Current Position = ${currentPosition.toJson()}");
    //    print("Current Rotation = ${currentRotation.toJson()}");
    currentPosition = rotate(currentPosition, currentRotation);
    if (currentPosition.number == 0) {
      timesZeroMet++;
    }
    //    print("New Position = ${currentPosition.toJson()}");
  }
  return timesZeroMet;
}

RotationWheelPosition rotate(
  RotationWheelPosition currentPosition,
  Rotation currentRotation,
) {
  for (int i = 0; i < currentRotation.distance; i++) {
    if (currentRotation.direction == Direction.right) {
      currentPosition = currentPosition.right!;
    } else {
      currentPosition = currentPosition.left!;
    }
  }
  return currentPosition;
}

enum Direction { left, right }

class Rotation {
  Direction direction;
  int distance;
  Rotation(this.direction, this.distance);

  Map<String, dynamic> toJson() => {
    'direction': direction,
    'distance': distance,
  };
}

Rotation mapRotation(String rotationAsString) {
  var directionAsString = rotationAsString.substring(0, 1);
  var distanceAsString = rotationAsString.substring(1);

  var direction = directionAsString == "L" ? Direction.left : Direction.right;
  var distance = int.parse(distanceAsString);

  return Rotation(direction, distance);
}

List<RotationWheelPosition> createRotationWheel() {
  List<RotationWheelPosition> rotationWheel = [];
  for (var i = 0; i < 100; i++) {
    rotationWheel.add(RotationWheelPosition(i));
  }

  for (var i = 1; i < 99; i++) {
    rotationWheel[i].left = rotationWheel[i - 1];
    rotationWheel[i].right = rotationWheel[i + 1];
  }

  rotationWheel[0].right = rotationWheel[1];
  rotationWheel[0].left = rotationWheel[99];

  rotationWheel[99].right = rotationWheel[0];
  rotationWheel[99].left = rotationWheel[98];

  return rotationWheel;
}

class RotationWheelPosition {
  int number;

  RotationWheelPosition(this.number);

  RotationWheelPosition? left;
  RotationWheelPosition? right;

  Map<String, dynamic> toJson() => {
    'number': number,
    'left': left!.number,
    'right': right!.number,
  };
}
