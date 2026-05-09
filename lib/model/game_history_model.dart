enum TichuType { none, small, large }

enum TichuState { none, ongoing, fail, success }

enum DoneState { ongoing, end }

enum OneTwoState { none, blue, red }

const String separation = '|';

class RoundHistoryModel {
  int blue = 0, red = 0;
  List<TichuType> tichuType = [
    TichuType.none,
    TichuType.none,
    TichuType.none,
    TichuType.none,
  ];
  List<TichuState> tichuState = [
    TichuState.none,
    TichuState.none,
    TichuState.none,
    TichuState.none,
  ];

  DoneState isdone = DoneState.ongoing;
  OneTwoState onetwo = OneTwoState.none;

  RoundHistoryModel();

  void resolveTichuScore(int winnerIndex) {
    if (onetwo == OneTwoState.blue) {
      blue = 200;
      red = 0;
    } else if (onetwo == OneTwoState.red) {
      red = 200;
      blue = 0;
    }

    for (int i = 0; i < 4; i++) {
      if (tichuType[i] != TichuType.none) {
        if (i == winnerIndex) {
          tichuState[i] = TichuState.success;
          if (i % 2 == 0) {
            blue += tichuType[i] == TichuType.small ? 100 : 200;
          } else {
            red += tichuType[i] == TichuType.small ? 100 : 200;
          }
        } else {
          tichuState[i] = TichuState.fail;
          if (i % 2 == 0) {
            blue -= tichuType[i] == TichuType.small ? 100 : 200;
          } else {
            red -= tichuType[i] == TichuType.small ? 100 : 200;
          }
        }
      }
    }
    isdone = DoneState.end;
  }
}

class GameHistoryModel {
  List<RoundHistoryModel> histories;
  int blueScore, redScore;

  GameHistoryModel(this.histories)
      : blueScore = histories.fold(0, (sum, history) => sum + history.blue),
        redScore = histories.fold(0, (sum, history) => sum + history.red);

  void addRound(RoundHistoryModel history) {
    histories.add(history);
    blueScore += history.blue;
    redScore += history.red;
  }

  bool isGameEnd() {
    const scoreCrit = 1000;
    if (blueScore == redScore) {
      return false;
    } else if (blueScore >= scoreCrit || redScore >= scoreCrit) {
      return true;
    } else if (blueScore <= -scoreCrit || redScore <= -scoreCrit) {
      return true;
    } else if ((blueScore - redScore).abs() >= scoreCrit) {
      return true;
    }
    return false;
  }
}
