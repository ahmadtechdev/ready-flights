import 'package:flutter/material.dart';
import 'colors.dart';

class AppConstants {
  // Screen dimensions and spacing
  static const double screenPadding = 20.0;
  static const double cardPadding = 16.0;
  static const double fieldHeight = 56.0;
  static const double buttonHeight = 48.0;
  static const double iconSize = 20.0;
  static const double smallIconSize = 16.0;
  static const double swapperIconSize = 32.0;
  
  // Border radius
  static const double borderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  
  // Text styles matching SastaTicket
  static const TextStyle appBarTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: TColors.primary,
  );
  
  static const TextStyle bannerTitleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static const TextStyle fieldLabelStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: Color(0xFF757575),
  );
  
  static const TextStyle fieldValueStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );
  
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: TColors.primary,
  );
  
  static const TextStyle statNumberStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  
  static const TextStyle statLabelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0xFF757575),
  );
  
  static const TextStyle customerServiceTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: TColors.primary,
  );
  
  static const TextStyle customerServiceSubtitleStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0xFF757575),
  );
  
  // Colors
  static const Color fieldBorderColor = Color(0xFFE0E0E0);
  static const Color fieldBackgroundColor = Color(0xFFF5F5F5);
  static const Color swapperIconColor = TColors.primary;
  static const Color tabInactiveColor = Color(0xFF757575);
  static const Color tabActiveColor = TColors.primary;
  
  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> swapperShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
}
