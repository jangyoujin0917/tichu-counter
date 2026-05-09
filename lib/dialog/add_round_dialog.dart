import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:tichu/model/command_history_model.dart';
import 'package:tichu/screen/main_screen.dart';

class AddRoundDialog extends StatefulWidget {
  final String blueName;
  final String redName;
  final List<String> playerNames;

  const AddRoundDialog({
    super.key,
    required this.blueName,
    required this.redName,
    required this.playerNames,
  });

  @override
  State<AddRoundDialog> createState() => _AddRoundDialogState();
}

class _AddRoundDialogState extends State<AddRoundDialog> {
  OneTwoSelection _selection = OneTwoSelection.none;
  bool _blueDragging = true;
  int _blueScore = 50;
  int _redScore = 50;

  Command _buildCommand(int winnerIndex) {
    return switch (_selection) {
      OneTwoSelection.none => ScoreCommand(
          winnerIndex: winnerIndex,
          blueScore: _blueScore,
          redScore: _redScore,
        ),
      OneTwoSelection.blue => OneTwoCommand(
          winnerIndex: winnerIndex,
          team: OneTwoTeam.blue,
        ),
      OneTwoSelection.red => OneTwoCommand(
          winnerIndex: winnerIndex,
          team: OneTwoTeam.red,
        ),
    };
  }

  void _submit(int winnerIndex) {
    Navigator.pop<Command>(
      context,
      _buildCommand(winnerIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                RadioGroup<OneTwoSelection>(
                  groupValue: _selection,
                  onChanged: (OneTwoSelection? value) {
                    setState(() {
                      _selection = value ?? _selection;
                    });
                  },
                  child: Row(
                    children: const [
                      Expanded(
                        child: RadioListTile<OneTwoSelection>(
                          title: Text("None"),
                          value: OneTwoSelection.none,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<OneTwoSelection>(
                          title: Text("Blue"),
                          value: OneTwoSelection.blue,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<OneTwoSelection>(
                          title: Text("Red"),
                          value: OneTwoSelection.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "Score",
                  style: TextStyle(fontSize: 22),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _scorePicker(
                      teamName: widget.blueName,
                      color: Colors.lightBlue,
                      isSelected: _blueDragging,
                      value: _blueScore,
                      onTap: () {
                        setState(() {
                          _blueDragging = true;
                        });
                      },
                      onChanged: (value) {
                        setState(() {
                          if (_blueDragging) {
                            _blueScore = value;
                            _redScore = 100 - value;
                          }
                        });
                      },
                    ),
                    _scorePicker(
                      teamName: widget.redName,
                      color: Colors.red,
                      isSelected: !_blueDragging,
                      value: _redScore,
                      onTap: () {
                        setState(() {
                          _blueDragging = false;
                        });
                      },
                      onChanged: (value) {
                        setState(() {
                          if (!_blueDragging) {
                            _redScore = value;
                            _blueScore = 100 - value;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          for (int i in [0, 2, 1, 3])
            TextButton(
              onPressed: () {
                _submit(i);
              },
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Text(
                  widget.playerNames[i],
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
  }

  Widget _scorePicker({
    required String teamName,
    required Color color,
    required bool isSelected,
    required int value,
    required VoidCallback onTap,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      children: [
        Text(
          teamName,
          style: TextStyle(
            fontSize: 22,
            color: color,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: isSelected ? Colors.grey[400] : Colors.transparent,
            ),
            child: NumberPicker(
              minValue: -25,
              maxValue: 125,
              step: 5,
              value: value,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
