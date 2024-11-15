import 'package:acesso_mapeado/controllers/sign_up_company_controller.dart';
import 'package:acesso_mapeado/pages/onboarding_page.dart';
import 'package:acesso_mapeado/shared/design_system.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class SignUpCompanyPage extends StatefulWidget {
  const SignUpCompanyPage({super.key});

  @override
  State<SignUpCompanyPage> createState() => _SignUpCompanyPageState();
}

class _SignUpCompanyPageState extends State<SignUpCompanyPage> {
  final _formKey = GlobalKey<FormState>();
  late SignUpCompanyController _controller;
  int _currentStep = 0;
  Map<String, TimeOfDay> _openingTimes = {};
  Map<String, TimeOfDay> _closingTimes = {};

  // Controllers para os campos do formulário
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cnpjController = MaskedTextController(mask: '00.000.000/0000-00');
  final _phoneController = MaskedTextController(mask: '(00) 00000-0000');
  final _addressController = TextEditingController();
  final _aboutController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cepController = MaskedTextController(mask: '00000-000');
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _workingHoursController = TextEditingController();

  // Controladores de tempo para cada dia da semana
  final Map<String, TextEditingController> _openingTimeControllers = {
    'Segunda-feira': TextEditingController(),
    'Terça-feira': TextEditingController(),
    'Quarta-feira': TextEditingController(),
    'Quinta-feira': TextEditingController(),
    'Sexta-feira': TextEditingController(),
    'Sábado': TextEditingController(),
    'Domingo': TextEditingController(),
  };

  final Map<String, TextEditingController> _closingTimeControllers = {
    'Segunda-feira': TextEditingController(),
    'Terça-feira': TextEditingController(),
    'Quarta-feira': TextEditingController(),
    'Quinta-feira': TextEditingController(),
    'Sexta-feira': TextEditingController(),
    'Sábado': TextEditingController(),
    'Domingo': TextEditingController(),
  };

  // Adicionar o accessibilityData como estado da página
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

  Future<Map<String, dynamic>> getAddressData(String cep) async {
    final response = await Dio().get('https://viacep.com.br/ws/$cep/json/');
    return response.data;
  }

  @override
  void initState() {
    super.initState();
    _controller = SignUpCompanyController(
      formKey: _formKey,
      nameController: _nameController,
      emailController: _emailController,
      cnpjController: _cnpjController,
      phoneController: _phoneController,
      aboutController: _aboutController,
      passwordController: _passwordController,
      confirmPasswordController: _confirmPasswordController,
      workingHoursController: _workingHoursController,
    );
  }

  void _onStepContinue() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _selectTime(
      BuildContext context, String day, bool isOpening) async {
    final TimeOfDay? picked = await showTimePicker(
        context: context, initialTime: const TimeOfDay(hour: 0, minute: 0));

    if (picked != null) {
      setState(() {
        if (isOpening) {
          _openingTimes[day] = picked;
          _openingTimeControllers[day]!.text = picked.format(context);
        } else {
          _closingTimes[day] = picked;
          _closingTimeControllers[day]!.text = picked.format(context);
        }
      });
    }
  }

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
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.black,
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.darkGray.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ],
          ),
        ),
        leading: IconButton(
          icon: Image.asset('assets/icons/arrow-left.png'),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingPage()),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepIndicator(0, 'Dados empresariais'),
                  _buildStepLine(),
                  _buildStepIndicator(1, 'Endereço'),
                  _buildStepLine(),
                  _buildStepIndicator(2, 'Acessibilidade'),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Cadastre-se',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  children: [
                    if (_currentStep == 0) _buildStepCompanyDetails(),
                    if (_currentStep == 1) _buildStepAddress(),
                    if (_currentStep == 2) _buildStepAccessibility(),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentStep > 0)
                          ElevatedButton(
                            onPressed: _onStepCancel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                color: AppColors.lightPurple,
                                width: 2,
                              ),
                            ),
                            child: const Text(
                              'Voltar',
                              style: TextStyle(
                                color: AppColors.lightPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: AppTypography.large,
                              ),
                            ),
                          ),
                        const Spacer(),
                        if (_currentStep == 2)
                          ElevatedButton(
                            onPressed: () => _controller.signUp(
                              context,
                              accessibilityData,
                              '${_addressController.text}, ${_numberController.text} ${_cityController.text} - ${_stateController.text}',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightPurple,
                            ),
                            child: const Text(
                              'Concluir',
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: AppTypography.large,
                              ),
                            ),
                          )
                        else
                          ElevatedButton(
                            onPressed: _onStepContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightPurple,
                            ),
                            child: const Text(
                              'Próximo',
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: AppTypography.large,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCompanyDetails() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nome fantasia',
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira o nome fantasia';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _cnpjController,
          decoration: const InputDecoration(
            labelText: 'CNPJ',
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira o CNPJ';
            }
            if (!_controller.isValidCNPJ(value)) {
              return 'CNPJ inválido';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Telefone',
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira o telefone';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'E-mail da empresa',
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira o e-mail';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'E-mail inválido';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _aboutController,
          decoration: const InputDecoration(
            labelText: 'Sobre a empresa',
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira uma descrição da empresa';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Senha',
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira a senha';
            }
            if (!_controller.isValidPassword(value)) {
              return 'A senha deve conter pelo menos 8 caracteres, incluindo maiúsculas, minúsculas, números e caracteres especiais';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _confirmPasswordController,
          decoration: const InputDecoration(
            labelText: 'Confirmar senha',
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, confirme a senha';
            }
            if (value != _passwordController.text) {
              return 'As senhas não correspondem';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildWorkingHours(),
      ],
    );
  }

  Widget _buildWorkingHours() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Horário de Funcionamento',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ..._openingTimeControllers.keys
            .map((day) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(day, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectTime(context, day, true),
                            child: TextFormField(
                              controller: _openingTimeControllers[day],
                              decoration: InputDecoration(
                                labelText: 'Abertura',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                hintText: _openingTimes[day]?.format(context) ??
                                    'Selecione',
                              ),
                              enabled: false,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectTime(context, day, false),
                            child: TextFormField(
                              controller: _closingTimeControllers[day],
                              decoration: InputDecoration(
                                labelText: 'Fechamento',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                hintText: _closingTimes[day]?.format(context) ??
                                    'Selecione',
                              ),
                              enabled: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ))
            .toList(),
      ],
    );
  }

  Widget _buildStepAddress() {
    return Column(
      children: [
        TextFormField(
          controller: _cepController,
          decoration: const InputDecoration(
            labelText: 'CEP',
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira o CEP';
            }
            return null;
          },
          onChanged: (value) async {
            if (value.length == 9) {
              Map<String, dynamic> addressData = await getAddressData(value);
              setState(() {
                _addressController.text = addressData['logradouro'];
                _neighborhoodController.text = addressData['bairro'];
                _cityController.text = addressData['localidade'];
                _stateController.text = addressData['uf'];
              });
            }
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Endereço',
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira o endereço';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _numberController,
          decoration: const InputDecoration(
            labelText: 'Número',
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira o número';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _neighborhoodController,
          decoration: const InputDecoration(
            labelText: 'Bairro',
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira o bairro';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _cityController,
          decoration: const InputDecoration(
            labelText: 'Cidade',
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira a cidade';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _stateController,
          decoration: const InputDecoration(
            labelText: 'Estado',
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira o estado';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStepAccessibility() {
    return Column(
      children: [
        const Text(
          "Marque as acessibilidades da sua empresa",
          style: TextStyle(
            color: AppColors.black,
            fontSize: AppTypography.large,
          ),
        ),
        const SizedBox(height: 20),
        ...accessibilityData.entries.map((entry) {
          // Usar o accessibilityData do estado
          String category = entry.key;
          List<Map<String, dynamic>> items = entry.value;
          return ExpansionTile(
            title: Text(
              category,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: AppTypography.medium,
                fontWeight: FontWeight.bold,
              ),
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
}
