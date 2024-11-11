import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Para gerenciar o estado de autenticação
class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  AuthProvider() {
    _user = _auth.currentUser;
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  // retorna o usuário logado
  User? get user => _user;

  // verifica se o usuário está logado
  bool get isAuthenticated => _user != null;
}

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      return _user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Erro ao realizar o login.');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  bool isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
}
