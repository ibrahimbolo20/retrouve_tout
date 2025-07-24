import 'package:flutter/material.dart';
import 'constants.dart';

ThemeData appTheme() {
  return ThemeData(
    primaryColor: AppConstants.primaryColor,
    fontFamily: 'SF Pro Display',
    textTheme: TextTheme(
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800]),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.grey[600]),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    ),
  );
}