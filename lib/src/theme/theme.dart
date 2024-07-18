import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
        surface: Colors.grey.shade300,
        primary: Colors.black,
        onPrimary: Color.fromARGB(255, 255, 120, 172),
        secondary: Colors.grey.shade200));

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
      surface: Colors.black,
      primary: Colors.white,
      onPrimary: Color.fromARGB(255, 86, 160, 194),
      secondary: Colors.grey.shade700,
      shadow: Colors.grey.shade200),
  shadowColor: Colors.grey.shade400,
);
