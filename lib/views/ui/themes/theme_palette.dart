import 'package:flutter/material.dart';

class ThemePalette {
  // Primary
  static Color primaryMain = const Color.fromRGBO(41, 98, 255, 1);
  static Color primaryLight = const Color.fromRGBO(212, 224, 255, 1);
  static Color primaryDark = const Color.fromRGBO(25, 59, 153, 1);

  // Secondary
  static Color secondaryMain = const Color.fromRGBO(255, 237, 41, 1);
  static Color secondaryLight = const Color.fromRGBO(255, 250, 191, 1);
  static Color secondaryDark = const Color.fromRGBO(153, 142, 25, 1);

  // Tertiary
  static Color tertiaryMain = const Color.fromRGBO(41, 211, 255, 1);
  static Color tertiaryLight = const Color.fromRGBO(212, 246, 255, 1);
  static Color tertiaryDark = const Color.fromRGBO(25, 127, 153, 1);

  // Base
  static Color paperLight = Colors.white;
  static Color paperDark = const Color.fromARGB(255, 36, 36, 36);
  static Color defaultLight = Colors.grey.shade50;
  static Color defaultDark = const Color.fromARGB(255, 18, 18, 18);

  // Gradient Mixed
  static LinearGradient gradientMixedLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[ThemePalette.secondaryLight, ThemePalette.tertiaryLight, ThemePalette.primaryLight]
  );

  static LinearGradient gradientMixedMain = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[ThemePalette.secondaryMain, ThemePalette.tertiaryMain, ThemePalette.primaryMain]
  );

  static LinearGradient gradientMixedDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[ThemePalette.secondaryDark, ThemePalette.tertiaryDark, ThemePalette.primaryDark]
  );

  // Gradient Primary
  static LinearGradient gradientPrimaryLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.topRight,
    colors: <Color>[ThemePalette.primaryLight, ThemePalette.primaryMain]
  );

  static LinearGradient gradientPrimaryDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.topRight,
    colors: <Color>[ThemePalette.primaryMain, ThemePalette.primaryDark]
  );

   // Gradient Secondary
  static LinearGradient gradientSecondaryLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.topRight,
    colors: <Color>[ThemePalette.secondaryLight, ThemePalette.secondaryMain]
  );

  static LinearGradient gradientSecondaryDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.topRight,
    colors: <Color>[ThemePalette.secondaryMain, ThemePalette.secondaryDark]
  );
}

ColorScheme colorScheme(BuildContext context) {
  return Theme.of(context).colorScheme;
}

Color darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount / 1.5).clamp(0.0, 1.0));

  return hslLight.toColor();
}