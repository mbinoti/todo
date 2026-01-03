import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'splash_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    if (isIOS) {
      return CupertinoApp(
        debugShowCheckedModeBanner: false,
        theme: CupertinoThemeData(
          scaffoldBackgroundColor: Color(0xFFF6F7F8),
          primaryColor: Color(0xFF21B66E),
        ),
        localizationsDelegates: const [
          DefaultWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        builder: _wrapWithSnackBarHost,
        home: const SplashPage(),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F7F8),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF21B66E)),
      ),
      home: const SplashPage(),
    );
  }
}

Widget _wrapWithSnackBarHost(BuildContext context, Widget? child) {
  return ScaffoldMessenger(
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: child ?? const SizedBox.shrink(),
    ),
  );
}
