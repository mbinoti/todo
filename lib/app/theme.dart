import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const Color _accentGreen = Color(0xFF21B66E);
const Color _scaffoldBackground = Color(0xFFF6F7F8);

ThemeData buildMaterialTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: _scaffoldBackground,
    colorScheme: ColorScheme.fromSeed(seedColor: _accentGreen),
  );
}

CupertinoThemeData buildCupertinoTheme() {
  return const CupertinoThemeData(
    scaffoldBackgroundColor: _scaffoldBackground,
    primaryColor: _accentGreen,
  );
}
