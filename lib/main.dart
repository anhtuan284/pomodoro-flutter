import 'package:flutter/material.dart';
import 'package:pomodoro/src/screens/pomodoro_screen.dart';
import 'package:pomodoro/src/theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: const PomodoroApp(),
  ));
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Timer',
      home: const PomodoroScreen(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
