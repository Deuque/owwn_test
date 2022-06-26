import 'package:flutter/material.dart';

abstract class AppColors {
  static const dark1 = Colors.black;
  static const dark2 = Color(0xFF2B2B2B);
  static const grey1 = Color(0xFFCFCCCC);
  static const blue1 = Color(0xFF2E22F7);
}

ThemeData darkTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: AppColors.dark1,
  inputDecorationTheme: const InputDecorationTheme(
    labelStyle: TextStyle(color: AppColors.grey1),
    border:
        UnderlineInputBorder(borderSide: BorderSide(color: AppColors.grey1)),
    enabledBorder:
        UnderlineInputBorder(borderSide: BorderSide(color: AppColors.grey1)),
    focusedBorder:
        UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      primary: AppColors.blue1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      fixedSize: const Size.fromHeight(59),
    ),
  ),
);
