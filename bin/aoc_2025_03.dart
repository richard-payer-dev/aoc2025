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
  print('Usage: dart aoc_2025_03.dart <flags> [arguments]');
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
      print('aoc_2025_03 version: $version');
      return;
    }
    if (results.flag('verbose')) {
      verbose = true;
    }

    // Act on the arguments provided.
    print('Positional arguments: ${results.rest}');

    var banks = mapToBanks(results.rest);
    var highJoltage = calculateMaxJoltageForBanks(banks, 12);
    print("joltage: $highJoltage");

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

int calculateMaxJoltageForBanks(List<Bank> banks, int bankSize) {
  List<ActivatedBatteries> acivatedBatteries = [];

  for (Bank currentBank in banks) {
    print(
      "currentBank: ${currentBank.batteries.map((b) => b.joltage).join("")}",
    );

    // order by joltage desc and position
    currentBank.batteries.sort((b1, b2) {
      var compareByJoltage = b2.joltage.compareTo(b1.joltage);
      if (compareByJoltage != 0) {
        return compareByJoltage;
      }

      return b1.position.compareTo(b2.position);
    });

    //    print(
    //      "currentBankOrdered: ${currentBank.batteries.map((b) => b.toJson()).join("")}",
    //    );

    // if the highest voltage is the last position, activate the second biggest battery
    var activatedBatteries = findActivations(currentBank, bankSize);
    print(
      "activatedBatteries: ${activatedBatteries.activatedBatteries}, value: ${activatedBatteries.getBankValue()}",
    );
    acivatedBatteries.add(activatedBatteries);
  }

  var sum = 0;
  for (ActivatedBatteries ab in acivatedBatteries) {
    sum += ab.getBankValue();
  }
  return sum;
}

ActivatedBatteries findActivations(
  Bank orderedBankByJoltage, [
  int bankSize = 2,
]) {
  ActivatedBatteries activatedBatteries = ActivatedBatteries();
  var latestPosition = 0;

  for (
    int currentlySearchedPosition = 1;
    currentlySearchedPosition <= bankSize;
    currentlySearchedPosition++
  ) {
    // wie viele müssen dahinter noch sein
    var openBatteryPositionsNeeded = bankSize - currentlySearchedPosition;
    /*
    print("######################################################");
    print("currently Searched Position $currentlySearchedPosition");
    print("openBatteryPositionsNeeded $openBatteryPositionsNeeded");
    print("latestPosition $latestPosition");
*/
    for (Battery currentBattery in orderedBankByJoltage.batteries) {
      /*
      print(
        "currentBattery checked for activation: ${currentBattery.toJson()}",
      );
      print(
        "orderedBankByJoltage.batteries.length (${orderedBankByJoltage.batteries.length}) - currentBattery.position (${currentBattery.position})) >= openBatteryPositionsNeeded ($openBatteryPositionsNeeded): ${(orderedBankByJoltage.batteries.length - currentBattery.position) >= openBatteryPositionsNeeded}",
      );
      print(
        "currentBattery.position (${currentBattery.position}) > latestPosition($latestPosition) (${currentBattery.position > latestPosition})",
      );
      print(
        "not already contains: ${(!activatedBatteries.activatedBatteries.contains(currentBattery))}",
      );
*/
      if (((orderedBankByJoltage.batteries.length - currentBattery.position) >=
              openBatteryPositionsNeeded) &&
          currentBattery.position > latestPosition &&
          (!activatedBatteries.activatedBatteries.contains(currentBattery))) {
        // activate the battery with the highest voltage
        activatedBatteries.activatedBatteries.add(currentBattery);
        latestPosition = currentBattery.position;
        //        print("Battery fits! take this one: ${currentBattery.toJson()}");
        break;
      }
    }
  }

  return activatedBatteries;
}

List<Bank> mapToBanks(List<String> inputArgs) {
  List<Bank> banks = [];
  for (String currentBatteryBankStr in inputArgs) {
    var joltagesPerBattery = currentBatteryBankStr.split('');
    var currentBank = Bank();
    for (int i = 0; i < joltagesPerBattery.length; i++) {
      currentBank.batteries.add(
        Battery(i + 1, int.parse(joltagesPerBattery[i])),
      );
    }
    banks.add(currentBank);
  }
  return banks;
}

class Battery {
  int position;
  int joltage;
  Battery(this.position, this.joltage);

  Map<String, dynamic> toJson() => {'position': position, 'joltage': joltage};
}

class Bank {
  List<Battery> batteries = [];

  Map<String, dynamic> toJson() => {'batteries': batteries};
}

class ActivatedBatteries {
  List<Battery> activatedBatteries = [];

  int getBankValue() {
    var multiplicator = 1;
    var bankValue = 0;
    for (Battery currentBattery in activatedBatteries.reversed) {
      bankValue += currentBattery.joltage * multiplicator;
      multiplicator *= 10;
    }

    return bankValue;
  }
}
