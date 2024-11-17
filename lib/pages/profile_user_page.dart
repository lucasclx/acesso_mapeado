import 'dart:convert';
import 'dart:io';
import 'package:acesso_mapeado/controllers/user_controller.dart';
import 'package:acesso_mapeado/shared/design_system.dart';
import 'package:acesso_mapeado/shared/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';

class ProfileUserPage extends StatefulWidget {
  ProfileUserPage({super.key});

  @override
  State<ProfileUserPage> createState() => _ProfileUserPageState();
}

class _ProfileUserPageState extends State<ProfileUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late TextEditingController _nameController;
  late MaskedTextController _dateOfBirthController;
  late MaskedTextController cpfController;
  late TextEditingController emailController;
  final UserController _authService = UserController();

  bool _isLoading = false;
  String? _imageBase64;
  int _currentStep = 0; // Variável para controlar o passo atual

  // Dados de acessibilidade
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

  @override
  void initState() {
    super.initState();
    final userController = Provider.of<UserController>(context, listen: false);
    final user = userController.userModel;

    _nameController = TextEditingController(text: user?.name ?? '');
    _dateOfBirthController = MaskedTextController(
      mask: '00/00/0000',
      text: user?.dateOfBirth != null
          ? DateFormat('dd/MM/yyyy').format(user!.dateOfBirth!)
          : '',
    );
    cpfController = MaskedTextController(
      mask: '000.000.000-00',
      text: user?.cpf ?? '',
    );
    emailController = TextEditingController(text: user?.email ?? '');
    _imageBase64 = user?.profilePictureUrl;

    if (user?.accessibilityData != null) {
      final userAccessibilityData = user!.accessibilityData!.toJson();
      for (var category in accessibilityData.keys) {
        if (userAccessibilityData[category] != null &&
            userAccessibilityData[category] is List) {
          for (var item in userAccessibilityData[category]) {
            final matchingItem = accessibilityData[category]?.firstWhere(
                (element) => element['tipo'] == item['tipo'],
                orElse: () => Map<String, dynamic>());
            if (matchingItem != null) {
              matchingItem['status'] = item['status'];
            }
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateOfBirthController.dispose();
    cpfController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);

    if (pickedFile != null) {
      if (mounted) {
        Provider.of<UserController>(context, listen: false)
            .updateProfilePhoto(File(pickedFile.path));
      }
    }
  }

  void _onStepContinue() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_currentStep < 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _saveChanges();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      String? birthDate;
      try {
        DateTime dateOfBirth =
            DateFormat('dd/MM/yyyy').parseStrict(_dateOfBirthController.text);
        birthDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(dateOfBirth);
      } catch (e) {
        birthDate = null;
      }

      // Coletar preferências de acessibilidade selecionadas
      final updatedAccessibilityData = {};
      accessibilityData.forEach((category, items) {
        updatedAccessibilityData[category] = items.map((item) {
          return {
            'tipo': item['tipo'],
            'status': item['status'],
          };
        }).toList();
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': _nameController.text,
        'dateOfBirth': birthDate,
        'accessibilityData': updatedAccessibilityData,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso')),
      );
    } on FirebaseAuthException catch (e) {
      Logger.logInfo('$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.message}')),
      );
    } catch (e) {
      Logger.logInfo('$e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar perfil')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showOpcoesBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                ),
                title: Text(
                  'Galeria',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                ),
                title: Text(
                  'Câmera',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                ),
                title: Text(
                  'Remover',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  if (mounted) {
                    Provider.of<UserController>(context, listen: false)
                        .removeProfilePhoto();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isValidCpf(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');

    if (cpf.length != 11) {
      return false;
    }

    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) {
      return false;
    }

    List<int> numbers = cpf.split('').map(int.parse).toList();

    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += numbers[i] * (10 - i);
    }
    int firstCheckDigit = (sum * 10 % 11) % 10;
    if (numbers[9] != firstCheckDigit) {
      return false;
    }

    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += numbers[i] * (11 - i);
    }
    int secondCheckDigit = (sum * 10 % 11) % 10;
    if (numbers[10] != secondCheckDigit) {
      return false;
    }

    return true;
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

  void _resetPassword() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if (email == null) {
      _showErrorDialog('Usuário não autenticado ou e-mail não encontrado.');
      return;
    }

    try {
      await _authService.resetPassword(email);
      _showSuccessDialog('E-mail de redefinição de senha enviado com sucesso!');
    } on FirebaseAuthException catch (e) {
      _showErrorDialog('Erro ao tentar redefinir a senha: ${e.message}');
    } catch (e) {
      _showErrorDialog('Erro desconhecido: ${e.toString()}');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Sucesso',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightPurple,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Erro',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightPurple,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType keyboardType,
    String validationMessage, {
    bool isEmail = false,
    bool isPassword = false,
    bool isCpf = false,
    bool isDateOfBirth = false,
    bool readOnly = false,
    FormFieldValidator<String>? validator,
  }) {
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
      readOnly: readOnly,
      onTap: readOnly
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Para alterar o $label, entre em contato com o suporte.'),
                ),
              );
            }
          : null,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return validationMessage;
            }
            if (isDateOfBirth && !isValidDateOfBirth(value)) {
              return 'Insira uma data de nascimento válida';
            }
            return null;
          },
    );
  }

  // Indicadores de passo
  Widget _buildStepIndicator(int stepIndex, String stepName) {
    return Column(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: _currentStep == stepIndex
              ? AppColors.lightPurple
              : AppColors.lightGray.withOpacity(0.3),
          child: Text(
            (stepIndex + 1).toString(),
            style: TextStyle(
              color:
                  _currentStep == stepIndex ? AppColors.white : AppColors.black,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stepName,
          style: const TextStyle(fontSize: 13, color: AppColors.black),
        ),
      ],
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 40,
      height: 2,
      color: AppColors.lightGray,
    );
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      children: [
        _buildTextField(
          _nameController,
          'Nome',
          TextInputType.text,
          'Por favor, insira seu nome',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          _dateOfBirthController,
          'Data de nascimento (dd/MM/yyyy)',
          TextInputType.datetime,
          'Por favor, insira uma data de nascimento válida',
          isDateOfBirth: true,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          cpfController,
          'CPF',
          TextInputType.number,
          '',
          isCpf: true,
          readOnly: true,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          emailController,
          'E-mail',
          TextInputType.emailAddress,
          '',
          isEmail: true,
          readOnly: true,
        ),
      ],
    );
  }

  Widget _buildAccessibilityStep() {
    return Column(
      children: [
        const Center(
          child: Text(
            textAlign: TextAlign.center,
            "Marque as acessibilidades que deseja encontrar nos estabelecimentos",
            style: TextStyle(
                color: AppColors.black, fontSize: AppTypography.large),
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        ...accessibilityData.entries.map((entry) {
          String category = entry.key;
          List<Map<String, dynamic>> items = entry.value;
          return ExpansionTile(
            title: Text(
              category,
              style: const TextStyle(
                  color: AppColors.black,
                  fontSize: AppSpacing.medium,
                  fontWeight: FontWeight.bold),
            ),
            children: items.map((item) {
              return CheckboxListTile(
                title: Text(
                  item["tipo"],
                  style: const TextStyle(color: AppColors.darkGray),
                ),
                value: item["status"],
                onChanged: (bool? value) {
                  setState(() {
                    item["status"] = value ?? false;
                  });
                },
                activeColor: AppColors.lightPurple,
                checkColor: AppColors.white,
              );
            }).toList(),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserController>(context).userModel;
    final imageUrl = userModel?.profilePictureUrl;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Indicadores de passo
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepIndicator(0, 'Dados Pessoais'),
                  _buildStepLine(),
                  _buildStepIndicator(1, 'Acessibilidade'),
                ],
              ),
              const SizedBox(height: 30),
              // Foto de perfil e opções
              const SizedBox(height: 15),
              Center(
                child: SizedBox(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: imageUrl != null
                            ? MemoryImage(base64Decode(imageUrl))
                            : const AssetImage(
                                    'assets/images/placeholder-user.png')
                                as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: const BoxDecoration(
                              color: AppColors.veryLightPurple,
                              shape: BoxShape.circle),
                          child: IconButton(
                            onPressed: _showOpcoesBottomSheet,
                            icon: const Icon(
                              Icons.camera_alt,
                              color: AppColors.lightPurple,
                              size: 23,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 45),
              // Passos do formulário
              if (_currentStep == 0) _buildPersonalInfoStep(),
              if (_currentStep == 1) _buildAccessibilityStep(),
              const SizedBox(height: 40),
              // Botões de navegação
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    ElevatedButton(
                      onPressed: _onStepCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                            color: AppColors.lightPurple, width: 2),
                        foregroundColor: AppColors.lightPurple,
                      ),
                      child: const Text('Voltar',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _onStepContinue,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightPurple),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.white)
                        : Text(
                            _currentStep == 1 ? 'Salvar Alterações' : 'Próximo',
                            style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 45),
              // Outras opções (redefinir senha, excluir conta, sair)
              Row(
                children: [
                  const Icon(Icons.lock_clock_outlined,
                      color: AppColors.lightPurple),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _resetPassword,
                    child: const Text(
                      'Redefinir senha',
                      style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.delete_outline,
                      color: AppColors.lightPurple),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Excluir conta',
                      style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.exit_to_app, color: AppColors.lightPurple),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Provider.of<UserController>(context, listen: false)
                          .logout();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        'onboarding',
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: const Text(
                      'Sair',
                      style: TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
