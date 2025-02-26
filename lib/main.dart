// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_quiz_app/screens/setup_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SetupScreen(),
    );
  }
}
