import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:curso_flutter/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Teste integrado de SimularOrcamento', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // ESPERA PELA RENDERIZAÇÃO INICIAL
    await tester.pumpAndSettle();

    // ENCONTRAR O PRIMEIRO SERVIÇO NA LISTA E AUMENTAR QUANTIDADE
    final addButton = find.descendant(
      of: find.byType(Card).first,
      matching: find.byIcon(Icons.add),
    );
    expect(addButton, findsOneWidget);

    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // VERIFICAR SE O TOTAL FOI ATUALIZADO
    final totalText = find.textContaining('Total: R\$');
    expect(totalText, findsOneWidget);

    // PEGAR O TEXTO DO TOTAL E VERIFICAR SE É MAIOR QUE 0
    final Text totalWidget = tester.widget(totalText);
    final totalStr = totalWidget.data!;
    final valorTotal = double.tryParse(
      totalStr.replaceAll(RegExp(r'[^\d.]'), ''),
    );
    expect(valorTotal, greaterThan(0.0));

    // TESTAR BOTÃO DE GERAR PDF (apenas verificação de disponibilidade)
    final pdfButton = find.byIcon(Icons.picture_as_pdf);
    expect(pdfButton, findsOneWidget);

    // TESTAR BOTÃO DE COMPARTILHAR
    final shareButton = find.byIcon(Icons.share);
    expect(shareButton, findsOneWidget);

    // TAP NOS BOTÕES (sem expectativa de resultado externo)
    await tester.tap(shareButton);
    await tester.pumpAndSettle();

    await tester.tap(pdfButton);
    await tester.pumpAndSettle();
  });
}
