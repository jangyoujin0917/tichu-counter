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

  RoundHistoryModel.fromJson(Map<String, dynamic> json)
      : blue = json['blue'],
        red = json['red'],
        tichuType = json['tichu_type']
            .toString()
            .split(separation)
            .map((e) => TichuType.values.byName(e))
            .toList(),
        tichuState = json['tichu_state']
            .toString()
            .split(separation)
            .map((e) => TichuState.values.byName(e))
            .toList(),
        onetwo = OneTwoState.values.byName(json['onetwo']),
        isdone = DoneState.values.byName(json['isdone']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'blue': blue,
      'red': red,
      'tichu_type': tichuType.map((e) => e.name).toList().join(separation),
      'tichu_state': tichuState.map((e) => e.name).toList().join(separation),
      'onetwo': onetwo.name,
      'isdone': isdone.name,
    };
    return json;
  }
}
