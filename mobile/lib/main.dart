import 'package:flutter/material.dart';

import 'src/home/home_screen.dart';

void main() {
  runApp(const HandwritingApp());
}

class HandwritingApp extends StatelessWidget {
  const HandwritingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Handwriting',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
