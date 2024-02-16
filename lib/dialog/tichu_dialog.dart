import 'package:flutter/material.dart';
import 'package:tichu/model/round_history_model.dart';

class TichuDialog extends StatelessWidget {
  const TichuDialog({
    super.key,
    required this.playerName,
    required this.tichu,
  });

  final List<String> playerName;
  final TichuType tichu;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: AlertDialog(
        title: Text(
          (tichu == TichuType.small) ? 'Small Tichu' : 'Large Tichu',
          style: const TextStyle(
            fontSize: 30,
          ),
        ),
        content: Text(
          (tichu == TichuType.small)
              ? 'Who called Small Tichu?'
              : 'Who called Large Tichu?',
          style: const TextStyle(
            fontSize: 22,
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
  }
}
