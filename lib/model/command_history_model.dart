import 'package:tichu/model/game_history_model.dart';

sealed class Command {
  const Command();
}

class TichuCommand extends Command {
  final int playerIndex;
  final bool isLarge;

  const TichuCommand({
    required this.playerIndex,
    required this.isLarge,
  });
}

enum OneTwoTeam { blue, red }

class OneTwoCommand extends Command {
  final int winnerIndex;
  final OneTwoTeam team;

  const OneTwoCommand({
    required this.winnerIndex,
    required this.team,
  });
}

class ScoreCommand extends Command {
  final int winnerIndex;
  final int blueScore, redScore;

  const ScoreCommand({
    required this.winnerIndex,
    required this.blueScore,
    required this.redScore,
  });
}

class CommandHistoryModel {
  final List<Command> commands;

  CommandHistoryModel(this.commands);

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
        current.resolveTichu(command.winnerIndex);
        histories.addRound(current);
        current = RoundHistoryModel();
      } else if (command is ScoreCommand) {
        current.blue = command.blueScore;
        current.red = command.redScore;
        current.resolveTichu(command.winnerIndex);
        histories.addRound(current);
        current = RoundHistoryModel();
      }
    }

    if (histories.histories.isEmpty ||
        histories.histories.last.isdone == DoneState.end) {
      histories.addRound(current);
    }

    return histories;
  }
}
