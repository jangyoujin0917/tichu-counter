import 'package:flutter/material.dart';

class RefreshDialog extends StatelessWidget {
  const RefreshDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: AlertDialog(
        title: const Text(
          'Refresh',
          style: TextStyle(
            fontSize: 30,
          ),
        ),
        content: const Text(
          'Do you really want to initalize scoreboard?',
          style: TextStyle(
            fontSize: 22,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Padding(
              padding: EdgeInsets.all(14.0),
              child: Text(
                "NO",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.red,
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Padding(
                padding: EdgeInsets.all(14.0),
                child: Text(
                  "YES",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
