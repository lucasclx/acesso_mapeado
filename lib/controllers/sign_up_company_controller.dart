import 'package:acesso_mapeado/models/accessibility_model.dart';
import 'package:acesso_mapeado/models/company_model.dart';
import 'package:acesso_mapeado/pages/company_home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:acesso_mapeado/shared/logger.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class SignUpCompanyController {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final MaskedTextController cnpjController;
  final TextEditingController phoneController;
  final TextEditingController aboutController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController workingHoursController;

  SignUpCompanyController({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.cnpjController,
    required this.phoneController,
    required this.aboutController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.workingHoursController,
  });

  bool isValidCNPJ(String cnpj) {
    cnpj = cnpj.replaceAll(RegExp(r'\D'), '');

    if (cnpj.length != 14) return false;

    if (RegExp(r'^(\d)\1*$').hasMatch(cnpj)) return false;

    List<int> numbers = cnpj.split('').map(int.parse).toList();

    // First check digit
    int sum = 0;
    int weight = 5;
    for (int i = 0; i < 12; i++) {
      sum += numbers[i] * weight;
      weight = weight == 2 ? 9 : weight - 1;
    }
    int digit1 = sum % 11 < 2 ? 0 : 11 - (sum % 11);
    if (numbers[12] != digit1) return false;

    // Second check digit
    sum = 0;
    weight = 6;
    for (int i = 0; i < 13; i++) {
      sum += numbers[i] * weight;
      weight = weight == 2 ? 9 : weight - 1;
    }
    int digit2 = sum % 11 < 2 ? 0 : 11 - (sum % 11);
    return numbers[13] == digit2;
  }

  bool isValidPassword(String password) {
    final passwordRegex = RegExp(
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  Future<void> signUp(
      BuildContext context,
      Map<String, List<Map<String, dynamic>>> accessibilityData,
      String address) async {
    if (formKey.currentState!.validate()) {
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

      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('As senhas não correspondem')),
        );
        return;
      }

      try {
        // Verificar se o CNPJ já existe no Firestore
        final cnpj = cnpjController.text.replaceAll(RegExp(r'\D'), '');
        final querySnapshot = await FirebaseFirestore.instance
            .collection('companies')
            .where('cnpj', isEqualTo: cnpj)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro: CNPJ já cadastrado')),
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

        AccessibilityModel accessibilityModel = AccessibilityModel(
          accessibilityData: selectedAccessibility,
        );

        // Update the working hours implementation
        List<WorkingHours> workingHours = [];

        // Get the working hours from the controllers
        for (String day in [
          'Segunda-feira',
          'Terça-feira',
          'Quarta-feira',
          'Quinta-feira',
          'Sexta-feira',
          'Sábado',
          'Domingo'
        ]) {
          String open = workingHoursData[day]?['open'] ?? 'Fechado';
          String close = workingHoursData[day]?['close'] ?? 'Fechado';

          workingHours.add(WorkingHours(
            day: day,
            open: open,
            close: close,
          ));
        }

        LatLng? latLong = await getLatLong(address);

        CompanyModel newCompany = CompanyModel(
          uuid: const Uuid().v4(),
          name: nameController.text,
          email: emailController.text,
          cnpj: cnpjController.text.replaceAll(RegExp(r'\D'), ''),
          phoneNumber: phoneController.text,
          workingHours: workingHours,
          address: address,
          about: aboutController.text,
          imageUrl: null,
          registrationDate: DateTime.now().toString(),
          accessibilityData: accessibilityModel,
          rating: 0.0,
          latitude: latLong?.latitude,
          longitude: latLong?.longitude,
          commentsData: [],
          ratings: [],
        );

        await FirebaseFirestore.instance
            .collection('companies')
            .doc(user!.uid)
            .set(newCompany.toJson())
            .catchError((error) {
          Logger.logInfo('Erro ao adicionar empresa ao Firestore: $error');
        });

        Logger.logInfo("Empresa adicionada com sucesso");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CompanyHomePage()),
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

// Add this field to store working hours data
final Map<String, Map<String, String>> workingHoursData = {};

// Add this method to update working hours
void updateWorkingHours(String day, String open, String close) {
  workingHoursData[day] = {
    'open': open,
    'close': close,
  };
}

Future<LatLng?> getLatLong(String address) async {
  final response = await Dio()
      .get('https://nominatim.openstreetmap.org/search?q=$address&format=json');

  if (response.statusCode == 200) {
    final data = response.data;
    return LatLng(double.parse(data[0]['lat']), double.parse(data[0]['lon']));
  } else {
    return null;
  }
}
