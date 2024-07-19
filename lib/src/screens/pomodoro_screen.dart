import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pomodoro/src/theme/theme_provider.dart';
import 'package:pomodoro/src/utils/bottom_dialog.dart';
import 'package:pomodoro/src/utils/config_manager.dart';
import 'package:flutter/services.dart';
import 'package:pomodoro/src/widgets/duration_button.dart';
import 'package:pomodoro/src/widgets/numeric_input_field.dart';
import 'package:pomodoro/src/widgets/timer_circle.dart';
import 'package:provider/provider.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  int _pomodoroDuration = 25 * 60;
  int _shortBreakDuration = 5 * 60;
  int _longBreakDuration = 15 * 60;
  bool _isDarkMode = false;

  int _remainingTime = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;

  bool _isWorking = true;
  bool _isLongBreak = false;

  int _completedCycles = 0;
  int _cyclesUntilLongBreak = 4;

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  final ConfigManager _configManager = ConfigManager();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadConfigurations();
  }

  /// Make sure the timer is stopped
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeNotifications() {
    // TODO: Initialize FlutterLocalNotificationsPlugin
  }

  Future<void> _loadConfigurations() async {
    final config = await _configManager.loadConfigurations();
    if (config.isNotEmpty) {
      setState(() {
        _pomodoroDuration = config['timers']['pomodoro'];
        _shortBreakDuration = config['timers']['short'];
        _longBreakDuration = config['timers']['long'];
        _cyclesUntilLongBreak = config['cyclesUntilLongBreak'];
        _remainingTime = _isWorking ? _pomodoroDuration : _shortBreakDuration;
        _isDarkMode = config['theme']['darkMode'] ?? false;
      });
      if (_isDarkMode) {
        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
      }
    }
  }

  Future<void> _saveConfigurations() async {
    Map<String, dynamic> config = {
      "timers": {
        "pomodoro": _pomodoroDuration,
        "short": _shortBreakDuration,
        "long": _longBreakDuration,
      },
      "cyclesUntilLongBreak": _cyclesUntilLongBreak,
      "theme": {
        "darkMode": _isDarkMode,
      }
    };
    await _configManager.saveConfigurations(config);
  }

  void _startTimer() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _showNotification('Time\'s up!', 'Take a break !');
          _handleTimerCompletion();
        }
      });
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingTime = _isWorking
          ? _pomodoroDuration
          : _isLongBreak
              ? _longBreakDuration
              : _shortBreakDuration;
    });
  }

  void _configureDurations() {
    TextEditingController pomodoroController =
        TextEditingController(text: (_pomodoroDuration ~/ 60).toString());
    TextEditingController shortBreakController =
        TextEditingController(text: (_shortBreakDuration ~/ 60).toString());
    TextEditingController longBreakController =
        TextEditingController(text: (_longBreakDuration ~/ 60).toString());
    TextEditingController cyclesController =
        TextEditingController(text: _cyclesUntilLongBreak.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Configure Durations'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NumericInputField(
                  controller: pomodoroController,
                  label: 'Pomodoro Duration (20 - 60 minutes)'),
              NumericInputField(
                  controller: shortBreakController,
                  label: 'Short Break Duration (5 - 10 minutes)'),
              NumericInputField(
                  controller: longBreakController,
                  label: 'Long Break Duration (15 - 30 minutes)'),
              NumericInputField(
                  controller: cyclesController,
                  label: 'Cycles Until Long Break'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dark Mode'),
                  Switch(
                    value: _isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        _isDarkMode = value;
                        Provider.of<ThemeProvider>(context, listen: false)
                            .toggleTheme();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_validateAndSaveDurations(
                    pomodoroController,
                    shortBreakController,
                    longBreakController,
                    cyclesController)) {
                  setState(() {
                    _pomodoroDuration = int.parse(pomodoroController.text) * 60;
                    _shortBreakDuration =
                        int.parse(shortBreakController.text) * 60;
                    _longBreakDuration =
                        int.parse(longBreakController.text) * 60;
                    _cyclesUntilLongBreak = int.parse(cyclesController.text);
                    _remainingTime =
                        _isWorking ? _pomodoroDuration : _shortBreakDuration;
                  });
                  _saveConfigurations();
                  showMessage(
                    context: context,
                    title: 'Setting Saved !!',
                    message: 'Your changes has been saved .',
                    type: MessageType.success,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  bool _validateAndSaveDurations(
    TextEditingController pomodoroController,
    TextEditingController shortBreakController,
    TextEditingController longBreakController,
    TextEditingController cyclesController,
  ) {
    final Map<String, Map<String, int?>> durations = {
      'Pomodoro': {
        'value': int.tryParse(pomodoroController.text),
        'min': 20,
        'max': 60
      },
      'Short Break': {
        'value': int.tryParse(shortBreakController.text),
        'min': 5,
        'max': 10
      },
      'Long Break': {
        'value': int.tryParse(longBreakController.text),
        'min': 15,
        'max': 30
      },
    };

    for (var entry in durations.entries) {
      String type = entry.key;
      int? value = entry.value['value'];
      int min = entry.value['min']!;
      int max = entry.value['max']!;

      if (value == null || value < min || value > max) {
        showMessage(
          context: context,
          title: 'Invalid Duration',
          message: 'Invalid $type duration.',
          type: MessageType.error,
        );
        return false;
      }
    }

    int? cyclesValue = int.tryParse(cyclesController.text);
    if (cyclesValue == null || cyclesValue < 1) {
      showMessage(
        context: context,
        title: 'Invalid Cycles',
        message: 'Cycles until long break must be at least 1.',
        type: MessageType.error,
      );
      return false;
    }

    return true;
  }

  void _showNotification(String title, String body) {
    // TODO: Implement the logic to show a local notification
  }

  void _handleTimerCompletion() {
    setState(() {
      if (_isWorking) {
        showMessage(
          context: context,
          title: 'Excellent !!',
          message: 'Take a break.',
          type: MessageType.success,
        );
        _completedCycles++;
        if (_completedCycles % _cyclesUntilLongBreak == 0) {
          _isLongBreak = true;
          _remainingTime = _longBreakDuration;
        } else {
          _remainingTime = _shortBreakDuration;
        }
      } else {
        showMessage(
          context: context,
          title: 'Break time over !!',
          message: 'Come back to work .',
          type: MessageType.warning,
        );
        _isLongBreak = false;
        _remainingTime = _pomodoroDuration;
      }
      _isWorking = !_isWorking;
      _startTimer();
    });
  }

  void _setTimerMode(String mode) {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      switch (mode) {
        case 'pomodoro':
          _isWorking = true;
          _remainingTime = _pomodoroDuration;
          _isLongBreak = false;
          break;
        case 'short break':
          _isWorking = false;
          _remainingTime = _shortBreakDuration;
          _isLongBreak = false;
          break;
        case 'long break':
          _isWorking = false;
          _remainingTime = _longBreakDuration;
          _isLongBreak = true;
          break;
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Pomodoro Timer'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 3.5,
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DurationButton(
                      text: "pomodoro",
                      isSelected: _isWorking,
                      onPressed: () => _setTimerMode('pomodoro')),
                  const SizedBox(width: 10),
                  DurationButton(
                      text: "short break",
                      isSelected: !_isWorking && !_isLongBreak,
                      onPressed: () => _setTimerMode('short break')),
                  const SizedBox(width: 10),
                  DurationButton(
                      text: "long break",
                      isSelected: !_isWorking && _isLongBreak,
                      onPressed: () => _setTimerMode('long break')),
                ],
              ),
              const SizedBox(height: 30),
              TimerCircle(
                totalTime: _isWorking
                    ? _pomodoroDuration
                    : _isLongBreak
                        ? _longBreakDuration
                        : _shortBreakDuration,
                remainingTime: _remainingTime,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                  onPressed: () {
                    if (!_isRunning) {
                      _startTimer();
                    } else {
                      _pauseTimer();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isRunning
                      ? const Text(
                          'PAUSE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      : const Text(
                          'START',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.refresh),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _configureDurations,
                    icon: const Icon(Icons.settings),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Completed Cycles: $_completedCycles',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
