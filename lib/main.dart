import 'package:acesso_mapeado/app.dart';
import 'package:acesso_mapeado/firebase_options.dart';
import 'package:acesso_mapeado/pages/home_page.dart';
import 'package:acesso_mapeado/pages/onboarding_page.dart';
import 'package:acesso_mapeado/pages/profile_user_page.dart';
import 'package:acesso_mapeado/pages/sign_in_page.dart';
import 'package:acesso_mapeado/pages/sign_up_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    App(initialRoutes: '/', routes: {
      '/': (context) => const OnboardingPage(),
      'signUp': (context) => const SignUpPage(),
      'signIn': (context) => const SignInPage(),
      'home': (context) => const HomePage(),
      'profile_user': (context) => const ProfileUserPage(),
    }),
  );
}
