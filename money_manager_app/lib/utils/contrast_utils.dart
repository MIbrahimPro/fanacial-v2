import 'package:flutter/painting.dart';

class ContrastUtils {
  static Color getTextColorForBackground(String hexColor) {
    final color = parseHex(hexColor);
    final hsl = HSLColor.fromColor(color);
    return hsl.lightness > 0.5 ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  }

  static Color parseHex(String hex) {
    final h = hex.replaceFirst('#', '');
    if (h.length == 6) {
      return Color(int.parse('FF$h', radix: 16));
    }
    return Color(int.parse(h, radix: 16));
  }
}
