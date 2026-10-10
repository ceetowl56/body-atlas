import 'package:flutter/material.dart';

/// Maps the icon names used in the JSON files to Flutter icons.
/// Add a line here when you add a body system with a new icon name.
IconData iconFor(String name) {
  switch (name) {
    case 'favorite':
      return Icons.favorite;
    case 'air':
      return Icons.air;
    case 'accessibility_new':
      return Icons.accessibility_new;
    case 'psychology':
      return Icons.psychology;
    case 'restaurant':
      return Icons.restaurant;
    case 'fitness_center':
      return Icons.fitness_center;
    default:
      return Icons.menu_book;
  }
}
