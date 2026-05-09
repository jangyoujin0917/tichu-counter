import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tichu/dialog/add_round_dialog.dart';
import 'package:tichu/dialog/refresh_dialog.dart';
import 'package:tichu/dialog/tichu_dialog.dart';
import 'package:tichu/model/command_history_model.dart';
import 'package:tichu/model/game_history_model.dart';
import 'package:tichu/widget/round_scoreboard.dart';
import 'package:tichu/dialog/settings_dialog.dart';
import 'package:tichu/widget/team_score.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:download/download.dart';
import 'package:file_picker/file_picker.dart';

const url = "https://github.com/jangyoujin0917/tichu-counter";
const playerNum = 4;
const defaultBlueName = "Blue Team";
const defaultRedName = "Red Team";
const defaultPlayerName = ['Player 1', 'Player 2', 'Player 3', 'Player 4'];

enum OneTwoSelection { none, blue, red }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final SharedPreferences prefs;

  bool isSaved = false;
  String blueName = defaultBlueName, redName = defaultRedName;
  List<String> playerNames = List<String>.from(defaultPlayerName);
  CommandHistoryModel commandHistory = CommandHistoryModel([]);

  void loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    isSaved = prefs.getBool('isSaved') ?? false;
    if (isSaved) {
      String jsonString = prefs.getString('history')!;
      commandHistory = CommandHistoryModel.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );

      blueName = prefs.getString('blueName')!;
      redName = prefs.getString('redName')!;
      playerNames = prefs.getStringList('playerName')!;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadPrefs();
  }

  void saveState() async {
    // save present info in prefs
    isSaved = true;
    await prefs.setBool('isSaved', true);
    await prefs.setString('blueName', blueName);
    await prefs.setString('redName', redName);
    await prefs.setStringList('playerName', playerNames);
    final jsonString = jsonEncode(commandHistory.toJson());
    await prefs.setString('history', jsonString);
    setState(() {});
  }

  void refreshState() async {
    // remove all saved things
    isSaved = false;
    blueName = defaultBlueName;
    redName = defaultRedName;
    playerNames = List<String>.from(defaultPlayerName);
    commandHistory = CommandHistoryModel([]);
    await prefs.setBool('isSaved', false);
    setState(() {});
  }

  void onRefresh() {
    showDialog(
      context: context,
      builder: (context) {
        return const RefreshDialog();
      },
    ).then((value) {
      if (value != null && value) {
        refreshState();
      }
    });
  }

  void onSettingSave() {
    final blueC = TextEditingController(text: blueName);
    final redC = TextEditingController(text: redName);
    final playerC = [
      for (int i = 0; i < playerNum; i++)
        TextEditingController(text: playerNames[i])
    ];
    showDialog(
        context: context,
        builder: (context) {
          return SettingsDialog(
            blueC: blueC,
            redC: redC,
            playerC: playerC,
          );
        }).then((_) {
      blueName = blueC.text.isNotEmpty ? blueC.text : defaultBlueName;
      redName = redC.text.isNotEmpty ? redC.text : defaultRedName;
      playerNames = [
        for (int i = 0; i < playerNum; i++)
          playerC[i].text.isNotEmpty ? playerC[i].text : defaultPlayerName[i]
      ];
      blueC.dispose();
      redC.dispose();
      for (var e in playerC) {
        e.dispose();
      }
      saveState();
    });
  }

  void onTichu(TichuType tichu) {
    showDialog(
      context: context,
      builder: (context) {
        return TichuDialog(
          playerNames: playerNames,
          tichu: tichu,
        );
      },
    ).then((player) {
      if (player != null) {
        commandHistory.commands.add(TichuCommand(
            playerIndex: player, isLarge: tichu == TichuType.large));
        saveState();
      }
    });
  }

  void onDelete() {
    if (commandHistory.commands.isNotEmpty) {
      commandHistory.commands.removeLast();
      saveState();
    }
  }

  void onAddRound() {
    showDialog<Command>(
        context: context,
        builder: (context) {
          return AddRoundDialog(
              blueName: blueName, redName: redName, playerNames: playerNames);
        }).then((Command? result) {
      if (result != null) {
        commandHistory.commands.add(result);
        saveState();
        setState(() {});
      }
    });
  }

  Future<void> onDownload() async {
    final now = DateTime.now();
    final gameHistory = commandHistory.toGameHistory();

    final exportData = <String, Object?>{
      'schemaVersion': 1,
      'date': now.toIso8601String(),
      'playerName': playerNames,
      'blueName': blueName,
      'redName': redName,
      'isGameEnd': gameHistory.isGameEnd(),
      'commandHistory': commandHistory.toJson(),
    };

    final jsonText = const JsonEncoder.withIndent('  ').convert(exportData);
    final fileName = 'tichu-counter-${_formatDateForFileName(now)}.json';

    final stream = Stream<int>.fromIterable(utf8.encode(jsonText));

    await download(stream, fileName);
  }

  String _formatDateForFileName(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');

    return '${date.year}-'
        '${two(date.month)}-'
        '${two(date.day)}_'
        '${two(date.hour)}-'
        '${two(date.minute)}-'
        '${two(date.second)}';
  }

  void onUpload() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
        withData: true,
      );

      // 사용자가 파일 선택을 취소한 경우
      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.single;
      final bytes = file.bytes;

      if (bytes == null) {
        throw const FormatException('파일 내용을 읽을 수 없습니다.');
      }

      final jsonText = utf8.decode(bytes);
      final decoded = jsonDecode(jsonText);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('최상위 JSON은 object여야 합니다.');
      }

      final schemaVersion = _readInt(decoded, 'schemaVersion');

      if (schemaVersion != 1) {
        throw FormatException(
          '지원하지 않는 schemaVersion입니다: $schemaVersion',
        );
      }

      final uploadedPlayerName = _readStringList(decoded, 'playerName');

      if (uploadedPlayerName.length != 4) {
        throw FormatException(
          'playerName은 정확히 4명이어야 합니다. 현재: ${uploadedPlayerName.length}명',
        );
      }

      final uploadedBlueName = _readString(decoded, 'blueName');
      final uploadedRedName = _readString(decoded, 'redName');

      final commandHistoryJson = _readMap(decoded, 'commandHistory');
      final uploadedCommandHistory = CommandHistoryModel.fromJson(
        commandHistoryJson,
      );

      // date, isGameEnd는 일부러 복원하지 않음.
      // isGameEnd는 필요할 때 commandHistory.toGameHistory().isGameEnd()로 다시 계산.

      if (!mounted) {
        return;
      }

      setState(() {
        playerNames
          ..clear()
          ..addAll(uploadedPlayerName);

        blueName = uploadedBlueName;
        redName = uploadedRedName;

        commandHistory.commands
          ..clear()
          ..addAll(uploadedCommandHistory.commands);
      });

      saveState();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('게임 기록을 불러왔습니다.'),
        ),
      );
    } on FormatException catch (e) {
      if (!mounted) {
        return;
      }

      _showUploadError('JSON 형식이 올바르지 않습니다.\n${e.message}');
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showUploadError('파일을 불러오지 못했습니다.\n$e');
    }
  }

  void _showUploadError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    GameHistoryModel histories = commandHistory.toGameHistory();
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Tichu Scoreboard',
          style: TextStyle(
            fontSize: 24,
          ),
        ),
        actions: [
          TextButton(
            child: const Text(
              "Made by @jangyoujin0917",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            onPressed: () {
              launchUrlString(url);
            },
          ),
          IconButton(
            onPressed: onDownload,
            iconSize: 30,
            icon: Icon(
              Icons.download_rounded,
              color: Colors.grey[800],
            ),
          ),
          IconButton(
            onPressed: onUpload,
            iconSize: 30,
            icon: Icon(
              Icons.upload_rounded,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: TeamScore(
                    name: blueName,
                    color: Colors.lightBlue[100]!,
                    score: histories.blueScore,
                  ),
                ),
                Expanded(
                  child: TeamScore(
                    name: redName,
                    color: Colors.red[100]!,
                    score: histories.redScore,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 15,
              ),
              color: Colors.grey[200],
              child: ListView.separated(
                  itemBuilder: (context, i) {
                    int index = histories.histories.length - i - 1;
                    RoundHistoryModel history = histories.histories[index];
                    return RoundScoreboard(
                      history: history,
                      index: index,
                      playerNames: playerNames,
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                        height: 7,
                        thickness: 1,
                        color: Colors.grey[300],
                      ),
                  itemCount: histories.histories.length),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[900],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ElevatedButton(
                      onPressed: () {
                        onTichu(TichuType.small);
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.grey[900]),
                      ),
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                              child: Text(
                            "ST",
                            style: TextStyle(
                              fontSize: 44,
                              color: Colors.grey[600],
                            ),
                          ))),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ElevatedButton(
                      onPressed: () {
                        onTichu(TichuType.large);
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.grey[900]),
                      ),
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                              child: Text(
                            "LT",
                            style: TextStyle(
                              fontSize: 44,
                              color: Colors.grey[600],
                            ),
                          ))),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: IconButton(
                      iconSize: 64,
                      onPressed: onAddRound,
                      icon: Icon(
                        Icons.add_box_outlined,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: IconButton(
                      iconSize: 64,
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: IconButton(
                      iconSize: 64,
                      onPressed: onRefresh,
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: IconButton(
                      iconSize: 64,
                      onPressed: onSettingSave,
                      icon: Icon(
                        Icons.settings,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

int _readInt(Map<String, dynamic> json, String key) {
  final value = json[key];

  if (value is int) {
    return value;
  }

  throw FormatException('$key must be an int. Actual value: $value');
}

String _readString(Map<String, dynamic> json, String key) {
  final value = json[key];

  if (value is String) {
    return value;
  }

  throw FormatException('$key must be a String. Actual value: $value');
}

List<String> _readStringList(Map<String, dynamic> json, String key) {
  final value = json[key];

  if (value is List && value.every((element) => element is String)) {
    return value.cast<String>();
  }

  throw FormatException('$key must be a List<String>. Actual value: $value');
}

Map<String, dynamic> _readMap(Map<String, dynamic> json, String key) {
  final value = json[key];

  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  throw FormatException('$key must be a JSON object. Actual value: $value');
}
