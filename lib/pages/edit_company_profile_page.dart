import 'dart:convert';
import 'dart:io';
import 'package:acesso_mapeado/models/accessibility_model.dart';
import 'package:acesso_mapeado/models/company_model.dart';
import 'package:acesso_mapeado/shared/design_system.dart';
import 'package:acesso_mapeado/shared/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:dio/dio.dart';

class EditCompanyProfilePage extends StatefulWidget {
  final CompanyModel company;

  const EditCompanyProfilePage({super.key, required this.company});

  @override
  State<EditCompanyProfilePage> createState() => _EditCompanyProfilePageState();
}

class _EditCompanyProfilePageState extends State<EditCompanyProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  // Controladores para os campos do formulário
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late MaskedTextController _cnpjController;
  late MaskedTextController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _aboutController;
  late MaskedTextController _cepController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

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

  // Controladores locais para campos adicionais
  late TextEditingController _numberController;
  late TextEditingController _neighborhoodController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;

  bool _isLoading = false;
  String? _imageBase64;
  File? _imageFile;
  int _currentStep = 0; // Variável para controlar o passo atual

  // Dados de acessibilidade como estado da página
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

  // Flag para rastrear a validade do CEP
  bool _isCEPValid = false;

  @override
  void initState() {
    super.initState();
    // Inicialização dos controladores com os dados existentes da empresa
    _nameController = TextEditingController(text: widget.company.name);
    _emailController = TextEditingController(text: widget.company.email);
    _cnpjController = MaskedTextController(
        mask: '00.000.000/0000-00', text: widget.company.cnpj);
    _phoneController = MaskedTextController(
        mask: '(00) 00000-0000', text: widget.company.phoneNumber);
    _addressController = TextEditingController(text: widget.company.address);
    _aboutController = TextEditingController(text: widget.company.about);
    _cepController =
        MaskedTextController(mask: '00000-000', text: ''); // Inicializado vazio
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _imageBase64 = widget.company.imageUrl;

    // Inicialização dos controladores locais para campos adicionais
    _numberController = TextEditingController();
    _neighborhoodController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();

    // Inicialização dos horários de funcionamento, se disponíveis
    if (widget.company.workingHours != null) {
      for (var hours in widget.company.workingHours!) {
        _openingTimeControllers[hours.day]?.text =
            hours.open != 'Fechado' ? hours.open! : '';
        _closingTimeControllers[hours.day]?.text =
            hours.close != 'Fechado' ? hours.close! : '';
      }
    }

    // Inicialização dos dados de acessibilidade
    if (widget.company.accessibilityData != null) {
      final userAccessibilityData = widget.company.accessibilityData!;
      for (var category in accessibilityData.keys) {
        if (userAccessibilityData.accessibilityData[category] != null &&
            userAccessibilityData.accessibilityData[category]
                is List<AccessibilityItem>) {
          for (var item in userAccessibilityData.accessibilityData[category]!) {
            final matchingItem = accessibilityData[category]?.firstWhere(
                (element) => element['tipo'] == item.type,
                orElse: () => {'tipo': '', 'status': false});
            if (matchingItem != null && matchingItem['tipo'] != '') {
              matchingItem['status'] = item.status;
            }
          }
        }
      }
    }

    // (Opcional) Você pode inicializar os controladores locais com dados existentes armazenados separadamente no Firestore, se aplicável.
  }

  @override
  void dispose() {
    // Dispose de todos os controladores
    _nameController.dispose();
    _emailController.dispose();
    _cnpjController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _aboutController.dispose();
    _cepController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (var controller in _openingTimeControllers.values) {
      controller.dispose();
    }
    for (var controller in _closingTimeControllers.values) {
      controller.dispose();
    }

    // Dispose dos controladores locais
    _numberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();

    super.dispose();
  }

  // Método para selecionar a imagem de perfil
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _imagePicker.pickImage(
      source: source,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });

      // Converter para base64
      final bytes = await _imageFile!.readAsBytes();
      final base64String = base64Encode(bytes);
      _imageBase64 = 'data:image/jpeg;base64,$base64String';
    }
  }

  // Método para exibir as opções de imagem
  void _showImageOptionsBottomSheet() {
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
                  child: const Icon(
                    Icons.photo_library,
                    color: AppColors.veryLightPurple,
                  ),
                ),
                title: Text(
                  'Galeria',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppColors.darkGray,
                  ),
                ),
                title: Text(
                  'Câmera',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_imageBase64 != null || _imageFile != null)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: const Icon(
                      Icons.delete,
                      color: AppColors.darkGray,
                    ),
                  ),
                  title: Text(
                    'Remover',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _imageBase64 = null;
                      _imageFile = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // Método para buscar dados do CEP
  Future<Map<String, dynamic>> getAddressData(String cep) async {
    final response = await Dio().get('https://viacep.com.br/ws/$cep/json/');
    return response.data;
  }

  // Método para selecionar horário
  Future<void> _selectTime(
      BuildContext context, String day, bool isOpening) async {
    TimeOfDay initialTime;

    if (isOpening) {
      if (_openingTimeControllers[day]!.text.isNotEmpty) {
        final parts = _openingTimeControllers[day]!.text.split(':');
        initialTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } else {
        initialTime = const TimeOfDay(hour: 9, minute: 0);
      }
    } else {
      if (_closingTimeControllers[day]!.text.isNotEmpty) {
        final parts = _closingTimeControllers[day]!.text.split(':');
        initialTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } else {
        initialTime = const TimeOfDay(hour: 18, minute: 0);
      }
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        if (isOpening) {
          _openingTimeControllers[day]!.text = picked.format(context);
        } else {
          _closingTimeControllers[day]!.text = picked.format(context);
        }
      });
    }
  }

  // Método para limpar horários
  void _clearWorkingHours() {
    setState(() {
      _openingTimeControllers.forEach((key, controller) => controller.clear());
      _closingTimeControllers.forEach((key, controller) => controller.clear());
    });
  }

  // Método para construir indicadores de passos
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

  // Método para construir linha entre indicadores
  Widget _buildStepLine() {
    return Container(
      width: 40,
      height: 2,
      color: AppColors.lightGray,
    );
  }

  // Método para construir os indicadores de passos
  Widget _buildStepIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepIndicator(0, 'Dados Empresariais'),
        _buildStepLine(),
        _buildStepIndicator(1, 'Endereço'),
        _buildStepLine(),
        _buildStepIndicator(2, 'Acessibilidade'),
      ],
    );
  }

  // Método para construir o passo de Dados Empresariais
  Widget _buildStepCompanyDetails() {
    return Column(
      children: [
        const SizedBox(height: 10),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nome Fantasia',
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
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
            if (!_isValidCNPJ(value)) {
              return 'CNPJ inválido';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'E-mail da Empresa',
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
          controller: _aboutController,
          decoration: const InputDecoration(
            labelText: 'Sobre a Empresa',
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor, insira uma descrição da empresa';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        // Campo para redefinir senha, opcional
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Nova Senha (opcional)',
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          obscureText: true,
          validator: (value) {
            if (value != null && value.isNotEmpty && !_isValidPassword(value)) {
              return 'A senha deve conter no mínimo 8 caracteres, incluindo: '
                  '\n- Uma letra maiúscula'
                  '\n- Uma letra minúscula'
                  '\n- Um número'
                  '\n- Um caractere especial';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _confirmPasswordController,
          decoration: const InputDecoration(
            labelText: 'Confirmar Nova Senha',
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          obscureText: true,
          validator: (value) {
            if (_passwordController.text.isNotEmpty) {
              if (value == null || value.isEmpty) {
                return 'Por favor, confirme a senha';
              }
              if (value != _passwordController.text) {
                return 'As senhas não correspondem';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildWorkingHours(),
      ],
    );
  }

  // Método para construir os horários de funcionamento
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
        ..._openingTimeControllers.keys.map((day) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(day, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(context, day, true),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _openingTimeControllers[day],
                          decoration: const InputDecoration(
                            labelText: 'Abertura',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            hintText: 'Opcional',
                          ),
                          validator: (value) {
                            String dayClosing =
                                _closingTimeControllers[day]!.text;
                            if ((value != null && value.isNotEmpty) &&
                                dayClosing.isEmpty) {
                              return 'Selecione o horário de fechamento';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(context, day, false),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _closingTimeControllers[day],
                          decoration: const InputDecoration(
                            labelText: 'Fechamento',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            hintText: 'Opcional',
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              String dayOpening =
                                  _openingTimeControllers[day]!.text;
                              if (dayOpening.isEmpty) {
                                return 'Selecione o horário de abertura primeiro';
                              }

                              // Converter os horários para minutos
                              TimeOfDay? opening = _parseTimeOfDay(dayOpening);
                              TimeOfDay? closing = _parseTimeOfDay(value);

                              if (opening != null && closing != null) {
                                final openingMinutes =
                                    opening.hour * 60 + opening.minute;
                                final closingMinutes =
                                    closing.hour * 60 + closing.minute;
                                if (closingMinutes <= openingMinutes) {
                                  return 'Fechamento deve ser após a abertura';
                                }
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          );
        }),
        const SizedBox(height: 10),
        Center(
          child: ElevatedButton(
            onPressed: _clearWorkingHours,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              side: const BorderSide(
                color: AppColors.lightPurple,
                width: 2,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Limpar Horários',
              style: TextStyle(
                color: AppColors.lightPurple,
                fontWeight: FontWeight.bold,
                fontSize: AppTypography.small,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Método auxiliar para converter string em TimeOfDay
  TimeOfDay? _parseTimeOfDay(String time) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) return null;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  // Método para construir o passo de Endereço
  Widget _buildStepAddress() {
    return Column(
      children: [
        const SizedBox(height: 10),
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
            if (!_isCEPValid) {
              return 'CEP inválido';
            }
            return null;
          },
          onChanged: (value) async {
            if (value.length == 9) {
              // Formato '00000-000'
              try {
                Map<String, dynamic> addressData =
                    await getAddressData(value.replaceAll('-', ''));
                if (addressData.containsKey('erro') &&
                    addressData['erro'] == true) {
                  setState(() {
                    _isCEPValid = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('CEP não encontrado')),
                  );
                } else {
                  setState(() {
                    _isCEPValid = true;
                    _addressController.text = addressData['logradouro'] ?? '';
                    _neighborhoodController.text = addressData['bairro'] ?? '';
                    _cityController.text = addressData['localidade'] ?? '';
                    _stateController.text = addressData['uf'] ?? '';
                  });
                }
              } catch (e) {
                setState(() {
                  _isCEPValid = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Erro ao buscar o endereço. Verifique o CEP.')),
                );
              }
            } else {
              setState(() {
                _isCEPValid = false;
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

  // Método para construir o passo de Acessibilidade
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
        }),
      ],
    );
  }

  // Método para obter os dados de horários de funcionamento
  Map<String, Map<String, String>> _getWorkingHoursData() {
    Map<String, Map<String, String>> data = {};
    for (String day in _openingTimeControllers.keys) {
      String open = _openingTimeControllers[day]!.text;
      String close = _closingTimeControllers[day]!.text;

      if (open.isNotEmpty || close.isNotEmpty) {
        data[day] = {
          'open': open.isNotEmpty ? open : 'Fechado',
          'close': close.isNotEmpty ? close : 'Fechado',
        };
      }
    }
    return data;
  }

  // Método para validar CNPJ
  bool _isValidCNPJ(String cnpj) {
    // Implementar validação de CNPJ conforme necessário
    // Aqui, apenas um exemplo simples
    final cnpjDigits = cnpj.replaceAll(RegExp(r'\D'), '');
    if (cnpjDigits.length != 14) return false;
    // Adicione validações adicionais se necessário
    return true;
  }

  // Método para validar senha
  bool _isValidPassword(String password) {
    // Validação: mínimo 8 caracteres, pelo menos uma maiúscula, uma minúscula, um número e um caractere especial
    final regex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return regex.hasMatch(password);
  }

  // Método para salvar as alterações
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      // Preparar os dados para atualização
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

      // Coletar horários de funcionamento
      final workingHoursData = _getWorkingHoursData();

      // Coletar dados adicionais do formulário
      final additionalData = {
        'number': _numberController.text,
        'neighborhood': _neighborhoodController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'cep': _cepController.text,
      };

      // Atualizar Firestore
      final updateData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'cnpj': _cnpjController.text,
        'phoneNumber': _phoneController.text,
        'address': _addressController.text,
        'about': _aboutController.text,
        'accessibilityData': updatedAccessibilityData,
        'workingHours': workingHoursData,
        'imageUrl': _imageBase64,
        ...additionalData, // Inclua os dados adicionais
      };

      // Se a senha for atualizada
      if (_passwordController.text.isNotEmpty) {
        updateData['password'] = _passwordController.text;
      }

      await FirebaseFirestore.instance
          .collection('companies')
          .doc(user.uid)
          .update(updateData);

      if (_passwordController.text.isNotEmpty) {
        await user.updatePassword(_passwordController.text);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso')),
      );
      Navigator.pop(context, true);
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

  // Método para continuar para o próximo passo
  void _onStepContinue() {
    if (_formKey.currentState!.validate()) {
      bool isValid = true;
      for (String day in _openingTimeControllers.keys) {
        String opening = _openingTimeControllers[day]!.text;
        String closing = _closingTimeControllers[day]!.text;
        if ((opening.isNotEmpty && closing.isEmpty) ||
            (opening.isEmpty && closing.isNotEmpty)) {
          isValid = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Por favor, complete os horários de $day')),
          );
          break;
        }
      }

      if (isValid) {
        if (_currentStep < 2) {
          setState(() {
            _currentStep++;
          });
        } else {
          _saveChanges();
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, corrija os erros antes de continuar')),
      );
    }
  }

  // Método para voltar para o passo anterior
  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: AppColors.lightPurple,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Indicadores de passo
              const SizedBox(height: 20),
              _buildStepIndicators(),
              const SizedBox(height: 30),
              // Foto de perfil e opções
              const SizedBox(height: 15),
              Center(
                child: SizedBox(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (_imageBase64 != null
                                    ? MemoryImage(base64Decode(
                                        _imageBase64!.split(',').last))
                                    : const AssetImage(
                                        'assets/images/img-company.png'))
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
                            onPressed: _showImageOptionsBottomSheet,
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
              if (_currentStep == 0) _buildStepCompanyDetails(),
              if (_currentStep == 1) _buildStepAddress(),
              if (_currentStep == 2) _buildStepAccessibility(),
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
                            _currentStep == 2 ? 'Salvar Alterações' : 'Próximo',
                            style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
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
