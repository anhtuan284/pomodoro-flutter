// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro/src/theme/theme_provider.dart';
import 'package:pomodoro/src/screens/pomodoro_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Pomodoro Timer initializes with correct default values',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MaterialApp(
          home: PomodoroScreen(),
        ),
      ),
    );

    expect(find.text('Pomodoro Timer'), findsOneWidget);
    expect(find.text('25:00'),
        findsOneWidget); // Default Pomodoro duration is 25 minutes
    expect(find.text('Completed Cycles: 0'), findsOneWidget);
  });

  testWidgets('Start button starts the timer', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MaterialApp(
          home: PomodoroScreen(),
        ),
      ),
    );

    expect(find.text('START'), findsOneWidget);
    await tester.tap(find.text('START'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('PAUSE'), findsOneWidget);
  });

  testWidgets('Pause button pauses the timer', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MaterialApp(
          home: PomodoroScreen(),
        ),
      ),
    );

    await tester.tap(find.text('START'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    await tester.tap(find.text('PAUSE'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('START'), findsOneWidget);
  });

  testWidgets('Reset button resets the timer', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MaterialApp(
          home: PomodoroScreen(),
        ),
      ),
    );

    await tester.tap(find.text('START'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    expect(find.text('25:00'), findsOneWidget);
  });

  testWidgets('Configure durations and save', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MaterialApp(
          home: PomodoroScreen(),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('Configure Durations'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextField, 'Pomodoro Duration (20 - 60 minutes)'),
        '30');
    await tester.enterText(
        find.widgetWithText(TextField, 'Short Break Duration (5 - 10 minutes)'),
        '6');
    await tester.enterText(
        find.widgetWithText(TextField, 'Long Break Duration (15 - 30 minutes)'),
        '20');
    await tester.enterText(
        find.widgetWithText(TextField, 'Cycles Until Long Break'), '4');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('30:00'), findsOneWidget);
  });
}
