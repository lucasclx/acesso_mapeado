import 'package:acesso_mapeado/pages/onboarding_page.dart';
import 'package:acesso_mapeado/shared/design_system.dart';
import 'package:flutter/material.dart';
import 'package:acesso_mapeado/controllers/sign_up_controller.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late SignUpController _signUpController;

  @override
  void initState() {
    super.initState();
    _signUpController = SignUpController(
      formKey: GlobalKey<FormState>(),
      nameController: TextEditingController(),
      emailController: TextEditingController(),
      cpfController: MaskedTextController(mask: '000.000.000-00'),
      dateOfBirthController: TextEditingController(),
      passwordController: TextEditingController(),
      confirmPasswordController: TextEditingController(),
    );
  }

  @override
  void dispose() {
    _signUpController.nameController.dispose();
    _signUpController.emailController.dispose();
    _signUpController.cpfController.dispose();
    _signUpController.dateOfBirthController.dispose();
    _signUpController.passwordController.dispose();
    _signUpController.confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(color: AppColors.white, boxShadow: [
            BoxShadow(
              color: AppColors.darkGray.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ]),
        ),
        leading: IconButton(
            icon: Image.asset('assets/icons/arrow-left.png'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OnboardingPage()),
              );
            }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _signUpController.formKey,
          child: ListView(
            children: [
              const SizedBox(height: 30),
              Center(
                child: const Text(
                  'Cadastre-se',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(_signUpController.nameController, 'Nome',
                  TextInputType.text, 'Por favor, insira seu nome'),
              const SizedBox(height: 20),
              _buildTextField(_signUpController.emailController, 'E-mail',
                  TextInputType.emailAddress, 'Por favor, insira seu e-mail',
                  isEmail: true),
              const SizedBox(height: 20),
              _buildTextField(_signUpController.cpfController, 'CPF',
                  TextInputType.number, 'Por favor, insira seu CPF',
                  isCpf: true),
              const SizedBox(height: 20),
              _buildTextField(
                  _signUpController.dateOfBirthController,
                  'Data de nascimento (YYYY-MM-DD)',
                  TextInputType.datetime,
                  'Por favor, insira sua data de nascimento'),
              const SizedBox(height: 20),
              _buildTextField(_signUpController.passwordController, 'Senha',
                  TextInputType.visiblePassword, 'Por favor, insira uma senha',
                  isPassword: true),
              const SizedBox(height: 20),
              _buildTextField(
                  _signUpController.confirmPasswordController,
                  'Confirmar senha',
                  TextInputType.visiblePassword,
                  'As senhas não correspondem',
                  isPassword: true,
                  confirmPassword: true),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _signUpController.signUp(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPurple,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                ),
                child: const Text(
                  'Cadastrar',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      TextInputType keyboardType, String validationMessage,
      {bool isEmail = false,
      bool isPassword = false,
      bool confirmPassword = false,
      bool isCpf = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      keyboardType: keyboardType,
      obscureText: isPassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Por favor, insira um e-mail válido';
        }
        if (isCpf && !_signUpController.isValidCpf(controller.text)) {
          return 'Por favor, insira um CPF válido';
        }
        if (confirmPassword &&
            value != _signUpController.passwordController.text) {
          return 'As senhas não correspondem';
        }
        return null;
      },
    );
  }
}
