import 'dart:math';

import 'package:flutter/material.dart';

/// Utility class for generating random, aesthetically pleasing pastel colors
/// suitable for sticky note backgrounds.
///
/// Uses a curated palette of soft, high-contrast colors to ensure readability
/// of dark text on the note surface.
class ColorGenerator {
  static final Random _random = Random();

  /// A curated list of pastel hex color codes that look great as sticky notes.
  static const List<int> _pastelColors = [
    0xFFFFEB3B, // Yellow
    0xFFFF8A80, // Light Red
    0xFF80D8FF, // Light Blue
    0xFFB9F6CA, // Light Green
    0xFFE1BEE7, // Light Purple
    0xFFFFE0B2, // Light Orange
    0xFFF8BBD0, // Light Pink
    0xFFB2DFDB, // Light Teal
    0xFFD1C4E9, // Lavender
    0xFFFFF9C4, // Pale Yellow
  ];

  /// Returns a random pastel color code from the curated palette.
  static int randomColorCode() {
    return _pastelColors[_random.nextInt(_pastelColors.length)];
  }

  /// Converts an integer color code to a Flutter [Color] object.
  static Color fromCode(int code) {
    return Color(code);
  }

  /// Returns a random default position offset for spawning new notes.
  /// Notes are placed within a reasonable area near the top-left of the screen
  /// so they don't spawn off-canvas.
  static double randomX(double maxWidth) {
    return 20.0 + _random.nextDouble() * (maxWidth - 180);
  }

  static double randomY(double maxHeight) {
    return 20.0 + _random.nextDouble() * (maxHeight - 180);
  }
}
