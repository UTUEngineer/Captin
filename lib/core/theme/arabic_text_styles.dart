import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class ArabicTextStyles {
  static const caltFeatures = [FontFeature.enable('calt')];

  static TextStyle cairo({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return GoogleFonts.cairo(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFeatures: caltFeatures,
    );
  }

  static TextStyle label({
    required double fontSize,
    Color color = Colors.white,
  }) {
    return cairo(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }
}

String ellipsizeLabel(String value, {int maxChars = 20}) {
  if (value.length <= maxChars) return value;
  return '${value.substring(0, maxChars)}…';
}
