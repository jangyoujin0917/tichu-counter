import 'package:flutter/material.dart';

class TeamNameSettings extends StatelessWidget {
  const TeamNameSettings({
    super.key,
    required this.order1,
    required this.order2,
    required this.color,
    required this.text,
    required this.nameController,
    required this.order1Controller,
    required this.order2Controller,
  });

  final String text;
  final int order1, order2;
  final Color color;
  final TextEditingController nameController,
      order1Controller,
      order2Controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$text Team',
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: 250,
          height: 50,
          child: TextFormField(
            autofocus: true,
            controller: nameController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: '$text Team Name',
              fillColor: color,
              filled: true,
            ),
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        const Text(
          'Player Name',
          style: TextStyle(fontSize: 22),
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          width: 250,
          height: 50,
          child: TextFormField(
            controller: order1Controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'Player $order1 Name',
              fillColor: color,
              filled: true,
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          width: 250,
          height: 50,
          child: TextFormField(
            controller: order2Controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'Player $order2 Name',
              fillColor: color,
              filled: true,
            ),
          ),
        ),
      ],
    );
  }
}
