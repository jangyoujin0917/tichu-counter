import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:tichu/dialog/refresh_dialog.dart';
import 'package:tichu/dialog/tichu_dialog.dart';
import 'package:tichu/model/command_history_model.dart';
import 'package:tichu/model/game_history_model.dart';
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
  String blueName = defaultBlueName, redName = defaultRedName;
  List<String> playerName = List<String>.from(defaultPlayerName);
  CommandHistoryModel commandHistory = CommandHistoryModel([]);

  void loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    isSaved = prefs.getBool('isSaved') ?? false;
    if (isSaved) {
      // List<String> tmp = prefs.getStringList('history')!;
      // histories =
      //    tmp.map((e) => RoundHistoryModel.fromJson(jsonDecode(e))).toList();

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

  void saveState() async {
    // save present info in prefs
    isSaved = true;
    await prefs.setBool('isSaved', true);
    await prefs.setString('blueName', blueName);
    await prefs.setString('redName', redName);
    await prefs.setStringList('playerName', playerName);
    setState(() {});
  }

  void refreshState() async {
    // remove all saved things
    isSaved = false;
    blueName = defaultBlueName;
    redName = defaultRedName;
    playerName = List<String>.from(defaultPlayerName);
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
    _selection = OneTwoSelection.none;
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
                        return RadioGroup<OneTwoSelection>(
                          groupValue: _selection,
                          onChanged: (OneTwoSelection? value) {
                            setState(() {
                              _selection = value ?? _selection;
                            });
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: RadioListTile<OneTwoSelection>(
                                  title: const Text("None"),
                                  value: OneTwoSelection.none,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<OneTwoSelection>(
                                  title: const Text("Blue"),
                                  value: OneTwoSelection.blue,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<OneTwoSelection>(
                                  title: const Text("Red"),
                                  value: OneTwoSelection.red,
                                ),
                              ),
                            ],
                          ),
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
          commandHistory.commands.add(ScoreCommand(
              winnerIndex: result, blueScore: _blueScore, redScore: _redScore));
        } else {
          commandHistory.commands.add(OneTwoCommand(
              winnerIndex: result,
              team: _selection == OneTwoSelection.blue
                  ? OneTwoTeam.blue
                  : OneTwoTeam.red));
        }

        saveState();
        setState(() {});
      }
    });
  }

  void onDownload() {
    /*
    final entire = EntireHistoryModel(
      histories: histories,
      playerName: playerName,
      blueName: blueName,
      redName: redName,
    );
    final String result = jsonEncode(entire);
    final stream = Stream.fromIterable(result.codeUnits);
    download(stream, "history.txt");
    */
  }

  void onUpload() async {
    /*
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['txt']);
    FilePickerResult? result = null;
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
    */
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
                      playerName: playerName,
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
