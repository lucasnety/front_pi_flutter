import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:curso_flutter/pages/chat_bot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'ChatBotPage - Interação do usuário com mensagem enviada e indicador de digitação',
    (WidgetTester tester) async {
      // INICIA O APP COM A CHATBOTPAGE
      await tester.pumpWidget(const MaterialApp(home: ChatBotPage()));
      await tester.pumpAndSettle();

      // VERIFICA SE A MENSAGEM INICIAL DO ASSISTENTE APARECE
      expect(
        find.textContaining('Olá, sou o assistente virtual'),
        findsOneWidget,
      );

      // ENCONTRA O CAMPO DE TEXTO E INSERE UMA MENSAGEM
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, 'Qual o valor do drywall no teto?');

      // PRESSIONA O BOTÃO DE ENVIO
      final sendButton = find.byIcon(Icons.send);
      expect(sendButton, findsOneWidget);
      await tester.tap(sendButton);

      // AGUARDA RECONSTRUÇÃO DA TELA
      await tester.pump();

      // VERIFICA SE A MENSAGEM DO USUÁRIO APARECE NA TELA
      expect(find.text('Qual o valor do drywall no teto?'), findsOneWidget);

      // VERIFICA SE O INDICADOR DE DIGITAÇÃO É EXIBIDO
      expect(
        find.textContaining('.'),
        findsOneWidget,
      ); // REPRESENTA OS PONTOS DA ANIMAÇÃO

      // SIMULA O TEMPO PARA PERMITIR RESPOSTA DA IA
      await tester.pump(const Duration(seconds: 3));

      // VERIFICA SE A IA RESPONDEU (PELO MENOS 2 MENSAGENS EXIBIDAS)
      expect(find.byType(SelectableText).evaluate().length, greaterThan(1));
    },
  );
}
