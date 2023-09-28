import 'package:flutter/material.dart';

Color stringToColor(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) {
    buffer.write('ff');
  }
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

String colorToString(Color color) {
  return color.value.toRadixString(16).substring(2).toUpperCase();
}
