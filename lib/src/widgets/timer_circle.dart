import 'package:flutter/material.dart';

class TimerCircle extends StatelessWidget {
  final int totalTime;
  final int remainingTime;

  const TimerCircle({
    Key? key,
    required this.totalTime,
    required this.remainingTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progress = remainingTime / totalTime;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 7,
            backgroundColor: Theme.of(context).colorScheme.surface,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        Text(
          '${(remainingTime ~/ 60).toString().padLeft(2, '0')}:${(remainingTime % 60).toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }
}
