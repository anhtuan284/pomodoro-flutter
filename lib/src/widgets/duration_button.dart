import 'package:flutter/material.dart';

class DurationButton extends StatefulWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  const DurationButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  _DurationButtonState createState() => _DurationButtonState();
}

class _DurationButtonState extends State<DurationButton> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => _setHover(true),
      onExit: (event) => _setHover(false),
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.primary,
          side: isHover
              ? BorderSide(
                  width: 2.5, color: Theme.of(context).colorScheme.onPrimary)
              : const BorderSide(width: 0, color: Colors.transparent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            color: widget.isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _setHover(bool hover) {
    setState(() {
      isHover = hover;
    });
  }
}
