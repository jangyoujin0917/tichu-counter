import 'dart:convert';

import 'package:tichu/model/round_history_model.dart';

class EntireHistoryModel {
  final List<RoundHistoryModel> histories;
  final List<String> playerName;
  final String blueName, redName;

  EntireHistoryModel({
    required this.histories,
    required this.playerName,
    required this.blueName,
    required this.redName,
  });

  EntireHistoryModel.fromJson(Map<String, dynamic> json)
      : histories = (json['histories'] as List)
            .map((e) => RoundHistoryModel.fromJson(jsonDecode(e)))
            .toList(),
        playerName =
            (json['playerName'] as List).map((e) => (e as String)).toList(),
        blueName = json['blueName'],
        redName = json['redName'];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'histories': histories.map((e) => jsonEncode(e)).toList(),
      'playerName': playerName,
      'blueName': blueName,
      'redName': redName,
    };
    return json;
  }
}
