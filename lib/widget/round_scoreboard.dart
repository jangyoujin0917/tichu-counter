import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tichu/model/round_history_model.dart';

class RoundScoreboard extends StatelessWidget {
  const RoundScoreboard({
    super.key,
    required this.history,
    required this.index,
    required this.playerName,
  });

  final RoundHistoryModel history;
  final int index;
  final List<String> playerName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      height: min(MediaQuery.of(context).size.height / 6, 120),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Row(
              children: [
                TichuBoard(
                  history: history,
                  playerName: playerName,
                  index: 0,
                  color: Colors.lightBlue[400]!,
                ),
                TichuBoard(
                  history: history,
                  playerName: playerName,
                  index: 2,
                  color: Colors.lightBlue[400]!,
                ),
                Expanded(
                  flex: 1,
                  child: (history.onetwo == OneTwoState.blue)
                      ? FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 30),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.lightBlue[400]!,
                            ),
                            child: const Center(
                              child: Text(
                                "1/2",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                      child: Text(
                    "${history.blue}",
                    style: const TextStyle(
                      fontSize: 36,
                    ),
                  )),
                ),
              ],
            ),
          ),
          VerticalDivider(
            thickness: 1,
            indent: 7,
            endIndent: 7,
            color: Colors.grey[500],
          ),
          Expanded(
            flex: 1,
            child: Center(
                child: Text(
              "${index + 1}",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            )),
          ),
          VerticalDivider(
            thickness: 1,
            indent: 7,
            endIndent: 7,
            color: Colors.grey[500],
          ),
          Expanded(
            flex: 6,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                      child: Text(
                    "${history.red}",
                    style: const TextStyle(
                      fontSize: 36,
                    ),
                  )),
                ),
                Expanded(
                  flex: 1,
                  child: (history.onetwo == OneTwoState.red)
                      ? FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 30),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.red[400]!,
                            ),
                            child: const Center(
                              child: Text(
                                "1/2",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ),
                TichuBoard(
                  history: history,
                  playerName: playerName,
                  index: 1,
                  color: Colors.red[400]!,
                ),
                TichuBoard(
                  history: history,
                  playerName: playerName,
                  index: 3,
                  color: Colors.red[400]!,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TichuBoard extends StatelessWidget {
  const TichuBoard({
    super.key,
    required this.history,
    required this.index,
    required this.color,
    required this.playerName,
  });

  final RoundHistoryModel history;
  final int index;
  final Color color;
  final List<String> playerName;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: (history.tichuType[index] == TichuType.none)
          ? Container()
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: switch (history.tichuState[index]) {
                    TichuState.ongoing => Colors.black,
                    TichuState.success => color,
                    TichuState.fail => Colors.grey,
                    TichuState.none => color,
                  },
                ),
                child: Text(
                  "${(history.tichuType[index] == TichuType.small) ? "ST" : "LT"}\n${playerName[index]}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
    );
  }
}
