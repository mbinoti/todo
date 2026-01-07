import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_todo/app/router.dart';
import 'package:app_todo/app/theme.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    if (isIOS) {
      return CupertinoApp(
        debugShowCheckedModeBanner: false,
        theme: buildCupertinoTheme(),
        localizationsDelegates: const [
          DefaultWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        builder: _wrapWithSnackBarHost,
        home: buildHome(),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildMaterialTheme(),
      home: buildHome(),
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
