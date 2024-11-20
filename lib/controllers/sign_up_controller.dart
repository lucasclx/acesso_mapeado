import 'package:acesso_mapeado/controllers/user_controller.dart';
import 'package:acesso_mapeado/models/accessibility_model.dart';
import 'package:acesso_mapeado/models/user_model.dart';
import 'package:acesso_mapeado/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:acesso_mapeado/shared/logger.dart';
import 'package:provider/provider.dart';

class SignUpController {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final MaskedTextController cpfController;
  final MaskedTextController dateOfBirthController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  final Map<String, List<Map<String, dynamic>>> accessibilityData = {
    "Acessibilidade Física": [
      {"tipo": "Rampas", "status": false},
      {"tipo": "Elevadores", "status": false},
      {"tipo": "Portas Largas", "status": false},
      {"tipo": "Banheiros Adaptados", "status": false},
      {"tipo": "Pisos e Superfícies Anti-derrapantes", "status": false},
      {"tipo": "Estacionamento Reservado", "status": false}
    ],
    "Acessibilidade Comunicacional": [
      {"tipo": "Sinalização com Braille e Pictogramas", "status": false},
      {"tipo": "Informações Visuais Claras e Contrastantes", "status": false},
      {"tipo": "Dispositivos Auditivos", "status": false},
      {"tipo": "Documentos e Materiais em Formatos Acessíveis", "status": false}
    ],
    "Acessibilidade Sensorial": [
      {"tipo": "Iluminação Adequada", "status": false},
      {"tipo": "Redução de Ruídos", "status": false}
    ],
    "Acessibilidade Atitudinal": [
      {"tipo": "Treinamento de Funcionários", "status": false},
      {"tipo": "Políticas Inclusivas", "status": false}
    ],
  };

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

  bool isValidDateOfBirth(String date) {
    try {
      final parts = date.split('/');
      if (parts.length != 3) return false;

      if (parts[2].length != 4) return false;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final parsedDate = DateTime(year, month, day);
      final now = DateTime.now();

      return parsedDate.isBefore(now);
    } catch (e) {
      return false;
    }
  }

  bool isValidPassword(String password) {
    final passwordRegex = RegExp(
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  Future<void> signUp(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      // Verificar se a senha atende aos requisitos
      if (!isValidPassword(passwordController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'A senha deve conter no mínimo 8 caracteres, incluindo:\n'
              '- Uma letra maiúscula\n'
              '- Uma letra minúscula\n'
              '- Um número\n'
              '- Um caractere especial',
            ),
          ),
        );
        return;
      }

      // Verificar se a confirmação da senha é igual à senha
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('As senhas não correspondem')),
        );
        return;
      }

      // Converter a data de nascimento para o formato correto
      final dateParts = dateOfBirthController.text.split('/');
      final parsedDate = DateTime(
        int.parse(dateParts[2]), // ano
        int.parse(dateParts[1]), // mês
        int.parse(dateParts[0]), // dia
      );

      if (!isValidDateOfBirth(dateOfBirthController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data de nascimento inválida')),
        );
        return;
      }

      try {
        // Verificar se o CPF já existe no Firestore
        final cpf = cpfController.text.replaceAll(RegExp(r'\D'), '');
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('cpf', isEqualTo: cpf)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro: CPF já cadastrado')),
          );
          return;
        }

        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        final user = userCredential.user;

        Map<String, List<AccessibilityItem>> selectedAccessibility = {};

        accessibilityData.forEach((category, items) {
          List<AccessibilityItem> selectedItems = items
              .where((item) => item['status'] == true)
              .map((item) => AccessibilityItem(
                    type: item['tipo'],
                    status: item['status'],
                  ))
              .toList();

          if (selectedItems.isNotEmpty) {
            selectedAccessibility[category] = selectedItems;
          }
        });

        // Cria a instância de AccessibilityModel com os dados selecionados
        AccessibilityModel accessibilityModel = AccessibilityModel(
          accessibilityData: selectedAccessibility,
        );

        UserModel newUser = UserModel(
          name: nameController.text,
          email: emailController.text,
          isCompany: false,
          cpf: cpfController.text.replaceAll(RegExp(r'\D'), ''),
          profilePictureUrl: 'user/profile',
          dateOfBirth: parsedDate,
          registrationDate: DateTime.now(),
          accessibilityData: accessibilityModel,
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
        final userController =
            Provider.of<UserController>(context, listen: false);
        userController.setUser(user);
        userController.updateUserModel(newUser);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro: e-mail já cadastrado')),
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
