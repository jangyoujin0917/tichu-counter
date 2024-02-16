import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:download/download.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:tichu/dialog/refresh_dialog.dart';
import 'package:tichu/dialog/tichu_dialog.dart';
import 'package:tichu/model/entire_history_model.dart';
import 'package:tichu/model/round_history_model.dart';
import 'package:tichu/widget/round_scoreboard.dart';
import 'package:tichu/dialog/settings_dialog.dart';
import 'package:tichu/widget/team_score.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
  OneTwoSelection _selection = OneTwoSelection.none;
  int _blueScore = 50, _redScore = 50;
  bool _blueDragging = true;

  bool isSaved = false;
  int blueScore = 0, redScore = 0;
  String blueName = defaultBlueName, redName = defaultRedName;
  List<String> playerName = List<String>.from(defaultPlayerName);
  List<RoundHistoryModel> histories = [RoundHistoryModel()];

  loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    isSaved = prefs.getBool('isSaved') ?? false;
    if (isSaved) {
      List<String> tmp = prefs.getStringList('history')!;
      histories =
          tmp.map((e) => RoundHistoryModel.fromJson(jsonDecode(e))).toList();

      blueName = prefs.getString('blueName')!;
      redName = prefs.getString('redName')!;
      playerName = prefs.getStringList('playerName')!;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadPrefs();
  }

  saveState() async {
    blueScore = histories.fold(0, (prev, e) => prev + e.blue);
    redScore = histories.fold(0, (prev, e) => prev + e.red);
    // save present info in prefs
    isSaved = true;
    await prefs.setBool('isSaved', true);
    await prefs.setString('blueName', blueName);
    await prefs.setString('redName', redName);
    await prefs.setStringList('playerName', playerName);
    final tmp = histories.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('history', tmp);
    setState(() {});
  }

  refreshState() async {
    // remove all saved things
    isSaved = false;
    blueName = defaultBlueName;
    redName = defaultRedName;
    blueScore = redScore = 0;
    playerName = List<String>.from(defaultPlayerName);
    histories = [RoundHistoryModel()];
    await prefs.setBool('isSaved', false);
    setState(() {});
  }

  onRefresh() {
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

  onSettingSave() {
    final blueC = TextEditingController(text: blueName);
    final redC = TextEditingController(text: redName);
    final playerC = [
      for (int i = 0; i < playerNum; i++)
        TextEditingController(text: playerName[i])
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
      playerName = [
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
          playerName: playerName,
          tichu: tichu,
        );
      },
    ).then((player) {
      if (player != null) {
        histories.last.tichuType[player] = tichu;
        histories.last.tichuState[player] = TichuState.ongoing;
        saveState();
      }
    });
  }

  void onDelete() {
    if (histories.length == 1) {
      histories = [RoundHistoryModel()];
    } else {
      switch (histories.last.isdone) {
        case DoneState.ongoing:
          histories.last = RoundHistoryModel();
          histories.removeAt(histories.length - 2);
          break;
        case DoneState.end:
          histories.last = RoundHistoryModel();
      }
    }
    saveState();
  }

  void onAddRound() {
    if (histories.last.isdone == DoneState.end) {
      return;
    }
    _blueDragging = true;
    _blueScore = _redScore = 50;
    showDialog(
      context: context,
      builder: (context) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: AlertDialog(
            title: const Text(
              'Score',
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            content: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                height: 335,
                width: 420,
                child: Column(
                  children: [
                    const Text(
                      'OneTwo',
                      style: TextStyle(fontSize: 22),
                    ),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return Row(
                          children: [
                            Expanded(
                              child: RadioListTile(
                                title: const Text("None"),
                                value: OneTwoSelection.none,
                                groupValue: _selection,
                                onChanged: (OneTwoSelection? value) {
                                  _selection = value ?? _selection;
                                  setState(() {});
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile(
                                title: const Text("Blue"),
                                value: OneTwoSelection.blue,
                                groupValue: _selection,
                                onChanged: (OneTwoSelection? value) {
                                  _selection = value ?? _selection;
                                  setState(() {});
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile(
                                title: const Text("Red"),
                                value: OneTwoSelection.red,
                                groupValue: _selection,
                                onChanged: (OneTwoSelection? value) {
                                  _selection = value ?? _selection;
                                  setState(() {});
                                },
                              ),
                            )
                          ],
                        );
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Score",
                      style: TextStyle(fontSize: 22),
                    ),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  blueName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.lightBlue,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _blueDragging = true;
                                    setState(() {});
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: _blueDragging
                                          ? Colors.grey[400]
                                          : Colors.transparent,
                                    ),
                                    child: NumberPicker(
                                      minValue: -25,
                                      maxValue: 125,
                                      step: 5,
                                      value: _blueScore,
                                      onChanged: (value) {
                                        setState(() {
                                          if (_blueDragging) {
                                            _blueScore = value;
                                            _redScore = 100 - value;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  redName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.red,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _blueDragging = false;
                                    setState(() {});
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: (!_blueDragging)
                                          ? Colors.grey[400]
                                          : Colors.transparent,
                                    ),
                                    child: NumberPicker(
                                      minValue: -25,
                                      maxValue: 125,
                                      step: 5,
                                      value: _redScore,
                                      onChanged: (value) {
                                        setState(() {
                                          if (!_blueDragging) {
                                            _redScore = value;
                                            _blueScore = 100 - value;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              for (int i in [0, 2, 1, 3])
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, i);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text(
                      playerName[i],
                      style: TextStyle(
                        fontSize: 20,
                        color: (i % 2 == 0) ? Colors.lightBlue : Colors.red,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    ).then((result) {
      if (result != null) {
        if (_selection == OneTwoSelection.none) {
          histories.last.blue = _blueScore;
          histories.last.red = _redScore;
        } else {
          if (_selection == OneTwoSelection.blue) {
            histories.last.blue = 200;
            histories.last.red = 0;
            histories.last.onetwo = OneTwoState.blue;
          } else {
            histories.last.red = 200;
            histories.last.blue = 0;
            histories.last.onetwo = OneTwoState.red;
          }
        }
        for (int i = 0; i < playerNum; i++) {
          TichuType type = histories.last.tichuType[i];
          if (type != TichuType.none) {
            if (result == i) {
              histories.last.tichuState[i] = TichuState.success;
              if (i % 2 == 0) {
                histories.last.blue += (type == TichuType.large) ? 200 : 100;
              } else {
                histories.last.red += (type == TichuType.large) ? 200 : 100;
              }
            } else {
              histories.last.tichuState[i] = TichuState.fail;
              if (i % 2 == 0) {
                histories.last.blue -= (type == TichuType.large) ? 200 : 100;
              } else {
                histories.last.red -= (type == TichuType.large) ? 200 : 100;
              }
            }
          }
        }
        histories.last.isdone = DoneState.end;

        saveState();
        if (blueScore < 1000 && redScore < 1000) {
          histories.add(RoundHistoryModel());
        }
        setState(() {});
      }
    });
  }

  onDownload() {
    final entire = EntireHistoryModel(
      histories: histories,
      playerName: playerName,
      blueName: blueName,
      redName: redName,
    );
    final String result = jsonEncode(entire);
    final stream = Stream.fromIterable(result.codeUnits);
    download(stream, "history.txt");
  }

  onUpload() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['txt']);
    if (result != null) {
      Uint8List? bytes = result.files.single.bytes;
      if (bytes != null) {
        String s = utf8.decode(bytes);
        try {
          final historyModel = EntireHistoryModel.fromJson(jsonDecode(s));
          histories = historyModel.histories;
          blueName = historyModel.blueName;
          redName = historyModel.redName;
          playerName = historyModel.playerName;
          setState(() {});
        } catch (e) {
          log("Strange type");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(
              Icons.download_rounded,
            ),
          ),
          IconButton(
            onPressed: onUpload,
            icon: const Icon(
              Icons.upload_rounded,
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
                    score: blueScore,
                  ),
                ),
                Expanded(
                  child: TeamScore(
                    name: redName,
                    color: Colors.red[100]!,
                    score: redScore,
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
                    int index = histories.length - i - 1;
                    RoundHistoryModel history = histories[index];
                    return RoundScoreboard(
                      history: history,
                      index: index,
                      playerName: playerName,
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                        height: 7,
                        thickness: 1,
                        color: Colors.grey[300],
                      ),
                  itemCount: histories.length),
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
                            MaterialStateProperty.all(Colors.grey[900]),
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
                            MaterialStateProperty.all(Colors.grey[900]),
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
