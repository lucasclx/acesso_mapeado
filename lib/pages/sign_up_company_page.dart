import 'package:acesso_mapeado/pages/onboarding_page.dart';
import 'package:acesso_mapeado/shared/design_system.dart';
import 'package:acesso_mapeado/shared/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpCompanyPage extends StatefulWidget {
  const SignUpCompanyPage({super.key});

  @override
  State<SignUpCompanyPage> createState() => _SignUpCompanyPageState();
}

class _SignUpCompanyPageState extends State<SignUpCompanyPage> {
  int _currentStep = 0;
  Map<String, TimeOfDay> _openingTimes = {};
  Map<String, TimeOfDay> _closingTimes = {};

  // Controladores de tempo para cada dia da semana (abertura e fechamento)
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
    // Chamada da biblioteca de relógio (substitua pela sua implementação)
    final TimeOfDay? picked = await showTimePicker(
        context: context, initialTime: const TimeOfDay(hour: 0, minute: 0));

    if (picked != null) {
      setState(() {
        if (isOpening) {
          _openingTimes[day] = picked; // Armazena o horário de abertura
          _openingTimeControllers[day]!.text = picked.format(context);
        } else {
          _closingTimes[day] = picked; // Armazena o horário de fechamento
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
        SizedBox(height: 4),
        Text(
          stepName,
          style: TextStyle(
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

  void _onFinish() {
    print("Cadastro concluído!");
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
                  offset: const Offset(0, 2))
            ]),
          ),
          leading: IconButton(
            icon: Image.asset('assets/icons/arrow-left.png'),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OnboardingPage()));
            },
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Bolinhas dos steps com linha
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepIndicator(0, 'Dados empresáriais'),
                _buildStepLine(), // Linha entre o primeiro e segundo step
                _buildStepIndicator(1, 'Endereço'),
                _buildStepLine(), // Linha entre o segundo e terceiro step
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
                children: <Widget>[
                  if (_currentStep == 0) _buildStepCompanyDetails(0),
                  if (_currentStep == 1) _buildStepAddress(1),
                  if (_currentStep == 2) _buildStepAccessibility(2),
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
                                color: AppColors.lightPurple, width: 2),
                            foregroundColor: AppColors.lightPurple,
                          ),
                          child: const Text(
                            'Voltar',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: AppTypography.large),
                          ),
                        ),
                      const Spacer(),
                      if (_currentStep == 2)
                        ElevatedButton(
                          onPressed: _onFinish,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightPurple),
                          child: const Text(
                            'Concluir',
                            style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: AppTypography.large),
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: _onStepContinue,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightPurple),
                          child: const Text(
                            'Próximo',
                            style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: AppTypography.large),
                          ),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Conteúdo do primeiro step - Dados Empresariais reformulado
  Widget _buildStepCompanyDetails(int i) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
              labelText: 'Nome fantasia',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)),
        ),
        const SizedBox(height: 20),
        TextFormField(
          decoration: const InputDecoration(
              labelText: 'CNPJ',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        TextFormField(
          decoration: const InputDecoration(
              labelText: 'Telefone',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        TextFormField(
          decoration: const InputDecoration(
              labelText: 'E-mail da empresa',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        TextFormField(
          decoration: const InputDecoration(
              labelText: 'Razão social',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 20),
        _buildWorkingHours(),
      ],
    );
  }

  Widget _buildWorkingHours() {
    List<String> daysOfWeek = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Horário de funcionamento',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        for (var day in daysOfWeek)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(day, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          _selectTime(context, day, true), // Para abertura
                      child: TextFormField(
                        controller: _openingTimeControllers[day],
                        decoration: InputDecoration(
                          labelText: 'Abertura',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          hintText: _openingTimes[day]?.format(context) ??
                              'Selecione',
                        ),
                        keyboardType:
                            TextInputType.number, // Aceita apenas números
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          LengthLimitingTextInputFormatter(
                              5), // Limita a 5 caracteres
                          // Máscara de tempo
                          _buildTimeMask(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          _selectTime(context, day, false), // Para fechamento
                      child: TextFormField(
                        controller: _closingTimeControllers[day],
                        decoration: InputDecoration(
                          labelText: 'Fechamento',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          hintText: _closingTimes[day]?.format(context) ??
                              'Selecione',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          LengthLimitingTextInputFormatter(5),
                          _buildTimeMask(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
      ],
    );
  }

// Máscara de tempo para o formato HH:MM, validando horas e minutos
  TextInputFormatter _buildTimeMask() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String text = newValue.text;

      text = text.replaceAll(RegExp(r'[^0-9]'), '');

      if (text.length > 4) {
        text = text.substring(0, 4);
      }

      if (text.length >= 1) {
        int firstDigit = int.tryParse(text.substring(0, 1)) ?? 0;
        if (firstDigit > 2) {
          return oldValue;
        }
      }

      if (text.length >= 3) {
        text = '${text.substring(0, 2)}:${text.substring(2)}';
      }

      if (text.length == 5) {
        int hour = int.tryParse(text.substring(0, 2)) ?? 0;
        int minute = int.tryParse(text.substring(3, 5)) ?? 0;

        if (hour > 23 || minute > 59) {
          return oldValue;
        }
      }

      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
  }

  // Conteúdo do segundo step - Endereço
  Widget _buildStepAddress(int i) {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
              labelText: 'CEP',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 20),
        TextFormField(
          decoration: InputDecoration(
              labelText: 'Endereço',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)),
        ),
        SizedBox(height: 20),
        TextFormField(
          decoration: InputDecoration(
              labelText: 'Número',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 20),
        TextFormField(
          decoration: InputDecoration(
              labelText: 'Bairro',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)),
        ),
        SizedBox(height: 20),
        TextFormField(
          decoration: InputDecoration(
              labelText: 'Cidade',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)),
        ),
      ],
    );
  }

  // Conteúdo do terceiro step - Configurar Acessibilidade
  Widget _buildStepAccessibility(int i) {
    return Column(
      children: [
        const Text(
          "Marque as acessibillidades da sua empresa",
          style:
              TextStyle(color: AppColors.black, fontSize: AppTypography.large),
        ),
        SizedBox(height: AppSpacing.large),
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
        })
      ],
    );
  }
}
