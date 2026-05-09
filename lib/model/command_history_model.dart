import 'package:tichu/model/game_history_model.dart';

sealed class Command {
  const Command();

  factory Command.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'tichu' => TichuCommand.fromJson(json),
      'onetwo' => OneTwoCommand.fromJson(json),
      'score' => ScoreCommand.fromJson(json),
      final type => throw FormatException('Unknown command type: $type'),
    };
  }

  Map<String, dynamic> toJson();
}

class TichuCommand extends Command {
  final int playerIndex;
  final bool isLarge;

  const TichuCommand({
    required this.playerIndex,
    required this.isLarge,
  });

  factory TichuCommand.fromJson(Map<String, dynamic> json) {
    return TichuCommand(
      playerIndex: _readInt(json, 'playerIndex'),
      isLarge: _readBool(json, 'isLarge'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'tichu',
      'playerIndex': playerIndex,
      'isLarge': isLarge,
    };
  }
}

enum OneTwoTeam { blue, red }

class OneTwoCommand extends Command {
  final int winnerIndex;
  final OneTwoTeam team;

  const OneTwoCommand({
    required this.winnerIndex,
    required this.team,
  });

  factory OneTwoCommand.fromJson(Map<String, dynamic> json) {
    return OneTwoCommand(
      winnerIndex: _readInt(json, 'winnerIndex'),
      team: _readOneTwoTeam(json, 'team'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'onetwo',
      'winnerIndex': winnerIndex,
      'team': team.name,
    };
  }
}

class ScoreCommand extends Command {
  final int winnerIndex;
  final int blueScore, redScore;

  const ScoreCommand({
    required this.winnerIndex,
    required this.blueScore,
    required this.redScore,
  });

  factory ScoreCommand.fromJson(Map<String, dynamic> json) {
    return ScoreCommand(
      winnerIndex: _readInt(json, 'winnerIndex'),
      blueScore: _readInt(json, 'blueScore'),
      redScore: _readInt(json, 'redScore'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'score',
      'winnerIndex': winnerIndex,
      'blueScore': blueScore,
      'redScore': redScore,
    };
  }
}

class CommandHistoryModel {
  final List<Command> commands;

  CommandHistoryModel(this.commands);

  factory CommandHistoryModel.fromJson(Map<String, dynamic> json) {
    final commandsJson = json['commands'];

    if (commandsJson is! List) {
      throw const FormatException('commands must be a List');
    }

    return CommandHistoryModel(
      commandsJson.map((commandJson) {
        if (commandJson is! Map<String, dynamic>) {
          throw const FormatException('Each command must be a JSON object');
        }

        return Command.fromJson(commandJson);
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commands': commands.map((command) => command.toJson()).toList(),
    };
  }

  GameHistoryModel toGameHistory() {
    GameHistoryModel histories = GameHistoryModel([]);
    RoundHistoryModel current = RoundHistoryModel();

    for (var command in commands) {
      if (command is TichuCommand) {
        current.tichuType[command.playerIndex] =
            command.isLarge ? TichuType.large : TichuType.small;
        current.tichuState[command.playerIndex] = TichuState.ongoing;
      } else if (command is OneTwoCommand) {
        current.onetwo = command.team == OneTwoTeam.blue
            ? OneTwoState.blue
            : OneTwoState.red;
        current.resolveTichuScore(command.winnerIndex);
        histories.addRound(current);
        current = RoundHistoryModel();
      } else if (command is ScoreCommand) {
        current.blue = command.blueScore;
        current.red = command.redScore;
        current.resolveTichuScore(command.winnerIndex);
        histories.addRound(current);
        current = RoundHistoryModel();
      }
    }

    if (histories.histories.isEmpty ||
        (histories.histories.last.isdone == DoneState.end &&
            !histories.isGameEnd())) {
      histories.addRound(current);
    }

    return histories;
  }
}

int _readInt(Map<String, dynamic> json, String key) {
  final value = json[key];

  if (value is int) {
    return value;
  }

  throw FormatException('$key must be an int. Actual value: $value');
}

bool _readBool(Map<String, dynamic> json, String key) {
  final value = json[key];

  if (value is bool) {
    return value;
  }

  throw FormatException('$key must be a bool. Actual value: $value');
}

OneTwoTeam _readOneTwoTeam(Map<String, dynamic> json, String key) {
  final value = json[key];

  if (value is! String) {
    throw FormatException('$key must be a String. Actual value: $value');
  }

  try {
    return OneTwoTeam.values.byName(value);
  } on ArgumentError {
    throw FormatException('Invalid OneTwoTeam value: $value');
  }
}
