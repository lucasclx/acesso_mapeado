import 'package:acesso_mapeado/models/user_model.dart';
import 'package:acesso_mapeado/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:acesso_mapeado/shared/logger.dart';

class SignUpController {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final MaskedTextController cpfController;
  final TextEditingController dateOfBirthController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  SignUpController({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.cpfController,
    required this.dateOfBirthController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  bool isValidCpf(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'\D'), '');
    if (cpf.length != 11) return false;

    List<int> digits = cpf.split('').map(int.parse).toList();
    int sum1 = 0, sum2 = 0;

    for (int i = 0; i < 9; i++) {
      sum1 += digits[i] * (10 - i);
      sum2 += digits[i] * (11 - i);
    }

    int check1 = (sum1 * 10) % 11 % 10;
    int check2 = (sum2 + check1 * 2) * 10 % 11 % 10;

    return check1 == digits[9] && check2 == digits[10];
  }

  Future<void> signUp(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      final parsedDate = DateTime.tryParse(dateOfBirthController.text);
      if (parsedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data de nascimento inválida')),
        );
        return;
      }

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        final user = userCredential.user;

        UserModel newUser = UserModel(
          name: nameController.text,
          email: emailController.text,
          isCompany: false,
          cpf: cpfController.text.replaceAll(RegExp(r'\D'), ''),
          profilePictureUrl: 'user/profile',
          dateOfBirth: parsedDate,
          registrationDate: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .set(newUser.toJson())
            .then((_) {
          Logger.logInfo("Usuário adicionado com sucesso");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cadastro realizado com sucesso')),
          );
        }).catchError((error) {
          Logger.logInfo('Erro ao adicionar usuário ao Firestore: $error');
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro e-mail já cadastrado')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Erro ao cadastrar')),
          );
        }
      }
    }
  }
}
