import 'package:flutter/material.dart';

class TeamScore extends StatelessWidget {
  final String name;
  final Color color;
  final int score;

  const TeamScore({
    super.key,
    required this.name,
    required this.color,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                name,
                style: const TextStyle(
                  fontSize: 40,
                ),
              ),
              Text(
                '$score',
                style: const TextStyle(fontSize: 70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
