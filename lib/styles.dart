import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class AppColors {
  static const dark1 = Colors.black;
  static const grey1 = Color(0xFFCFCCCC);
  static const grey2 = Color(0xFFA7A7A7);
  static const grey3 = Color(0xFF393939);
  static const grey4 = Color(0xFF2B2B2B);
  static const blue1 = Color(0xFF2E22F7);
}

ThemeData darkTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: AppColors.dark1,
  inputDecorationTheme: const InputDecorationTheme(
    labelStyle: TextStyle(color: AppColors.grey1),
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
  appBarTheme: const AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle.light,
    color: AppColors.dark1,
    iconTheme: IconThemeData(color: Colors.white),
  ),
);
