import 'package:acesso_mapeado/app.dart';
import 'package:acesso_mapeado/firebase_options.dart';
import 'package:acesso_mapeado/models/company_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // runApp(const App());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => CompanyState()), // Fornecendo o estado das empresas
      ],
      child: const App(), // Inicializa o app
    ),
  );
}
