import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  get email => null;

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Erro ao realizar o login. Por favor, tente novamente.');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  isValidEmail() {
    return email.contains('@') && email.contains('.');
  }

 Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow; // Repassa o erro para ser tratado onde a função é chamada
    }
  }
}
