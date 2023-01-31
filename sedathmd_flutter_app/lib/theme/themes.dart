import 'package:flutter/material.dart';

class Themes {
  static final lightTheme =
      ThemeData(colorScheme: const ColorScheme.light()).copyWith(
    appBarTheme: const AppBarTheme(
        color: Colors.white,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black)),
    textTheme: const TextTheme(
      headline1: TextStyle(color: Colors.black),
      headline2: TextStyle(color: Colors.black),
      headline3: TextStyle(color: Colors.black),
      headline4: TextStyle(color: Colors.black),
      headline5: TextStyle(color: Colors.black),
      headline6: TextStyle(color: Colors.black),
      subtitle1: TextStyle(color: Colors.black),
      subtitle2: TextStyle(color: Colors.black),
      bodyText1: TextStyle(color: Colors.black),
      bodyText2: TextStyle(color: Colors.black),
    ),
    scaffoldBackgroundColor: Colors.white,
  );

  static final darkTheme = ThemeData(colorScheme: const ColorScheme.dark())
      .copyWith(
          cardTheme: const CardTheme(color: Colors.black12),
          appBarTheme: const AppBarTheme(
              centerTitle: true, backgroundColor: Colors.black),
          scaffoldBackgroundColor: Colors.black);
}
