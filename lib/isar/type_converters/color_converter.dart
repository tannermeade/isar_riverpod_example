import 'package:flutter/material.dart';

class ColorConverter {
  const ColorConverter();

  static Color fromIsar(String colorHex) => _colorFromHex(colorHex);

  static String toIsar(Color color) => _colorToHex(color);

  static Color _colorFromHex(String hexString) {
    if (hexString.isEmpty) return Colors.transparent;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String _colorToHex(Color color, {bool leadingHashSign = true}) => '${leadingHashSign ? '' : ''}'
      '${color.alpha.toRadixString(16).padLeft(2, '0')}'
      '${color.red.toRadixString(16).padLeft(2, '0')}'
      '${color.green.toRadixString(16).padLeft(2, '0')}'
      '${color.blue.toRadixString(16).padLeft(2, '0')}';
}
