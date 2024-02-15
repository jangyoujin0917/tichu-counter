import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tichu/screen/main_screen.dart';

void main() {
  runApp(const ScoreboardApp());
}

class ScoreboardApp extends StatelessWidget {
  const ScoreboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tichu Scoreboard',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
        scrollbars: false,
      ),
      home: const MainScreen(),
    );
  }
}
