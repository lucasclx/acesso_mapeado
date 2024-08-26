import 'package:acesso_mapeado/pages/onboarding_page.dart';
import 'package:acesso_mapeado/pages/splash_page.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key, required String initialRoutes, required Map<String, Function(dynamic context)> routes});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // home: SplashPage(),
      home: OnboardingPage(),
    );
  }
}
