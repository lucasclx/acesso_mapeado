import 'package:acesso_mapeado/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Verifica se os elementos da Onboarding Page estão presentes',
      (WidgetTester tester) async {
    // Renderiza a Onboarding Page no ambiente de teste
    await tester.pumpWidget(MaterialApp(home: OnboardingPage()));

    // Verifica se o título principal está presente
    expect(find.text('Cadastre-se'), findsOneWidget);

    // Verifica se o botão "Próximo" está presente
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Sou uma empresa'), findsOneWidget);
  });
// {"conversationId":"f47b4c45-c36f-47d6-9355-bdca8b88fc6d","source":"instruct"}
}
