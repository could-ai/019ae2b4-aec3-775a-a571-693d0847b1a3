import 'package:flutter/material.dart';

class XPColors {
  static const Color background = Color(0xFFC0C0C0);
  static const Color white = Colors.white;
  static const Color gray = Color(0xFF808080);
  static const Color black = Colors.black;
  
  // Number colors
  static const Color num1 = Color(0xFF0000FF);
  static const Color num2 = Color(0xFF008000);
  static const Color num3 = Color(0xFFFF0000);
  static const Color num4 = Color(0xFF000080);
  static const Color num5 = Color(0xFF800000);
  static const Color num6 = Color(0xFF008080);
  static const Color num7 = Color(0xFF000000);
  static const Color num8 = Color(0xFF808080);

  static Color getNumberColor(int number) {
    switch (number) {
      case 1: return num1;
      case 2: return num2;
      case 3: return num3;
      case 4: return num4;
      case 5: return num5;
      case 6: return num6;
      case 7: return num7;
      case 8: return num8;
      default: return black;
    }
  }
}
