import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'profile_model.dart';
import 'profile_model.dart';
import 'splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final profileModel = ProfileModel();
  await profileModel.loadFromPrefs();
  runApp(MainApp(profileModel: profileModel));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.profileModel});

  final ProfileModel profileModel;

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    if (isIOS) {
      return ChangeNotifierProvider(
        value: profileModel,
        child: CupertinoApp(
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
        ),
      );
    }
    return ChangeNotifierProvider(
      value: profileModel,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF6F7F8),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF21B66E)),
        ),
        home: const SplashPage(),
      ),
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
