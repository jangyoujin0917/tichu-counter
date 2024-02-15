import 'package:flutter/material.dart';
import 'package:tichu/widget/team_name_settings.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({
    super.key,
    required this.blueC,
    required this.redC,
    required this.playerC,
  });

  final TextEditingController blueC;
  final TextEditingController redC;
  final List<TextEditingController> playerC;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Settings',
        style: TextStyle(
          fontSize: 30,
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30.0,
          vertical: 10.0,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            height: 320,
            width: 600,
            child: Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TeamNameSettings(
                        text: 'Blue',
                        order1: 1,
                        order2: 3,
                        color: Colors.lightBlue[100]!,
                        nameController: blueC,
                        order1Controller: playerC[0],
                        order2Controller: playerC[2],
                      ),
                      const VerticalDivider(
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      TeamNameSettings(
                        text: 'Red',
                        order1: 2,
                        order2: 4,
                        color: Colors.red[100]!,
                        nameController: redC,
                        order1Controller: playerC[1],
                        order2Controller: playerC[3],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Padding(
            padding: EdgeInsets.all(14.0),
            child: Text(
              "SAVE",
              style: TextStyle(
                fontSize: 20,
                color: Colors.purple,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
