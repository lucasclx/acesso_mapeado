import 'package:acesso_mapeado/pages/company_home_page.dart';
import 'package:acesso_mapeado/pages/home_page.dart';
import 'package:acesso_mapeado/pages/onboarding_page.dart';
import 'package:acesso_mapeado/pages/profile_user_page.dart';
import 'package:acesso_mapeado/pages/sign_in_page.dart';
import 'package:acesso_mapeado/pages/sign_up_page.dart';
import 'package:acesso_mapeado/pages/splash_page.dart';
import 'package:acesso_mapeado/pages/support_page.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // desativar o banner
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        'signUp': (context) => const SignUpPage(),
        'signIn': (context) => const SignInPage(),
        'home': (context) => const HomePage(),
        'profile_user': (context) => const ProfileUserPage(),
        'onboarding': (context) => const OnboardingPage(),
        'company_home': (context) => const CompanyHomePage(),
        'support': (context) => const SupportPage(),
      },
    );
  }
}
