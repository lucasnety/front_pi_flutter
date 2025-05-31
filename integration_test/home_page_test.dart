import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:curso_flutter/pages/home_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Renderização básica da HomePage', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    // Verifica se alguns elementos principais da HomePage estão presentes
    expect(find.text('Como podemos ajudar ?'), findsOneWidget);
    expect(find.text('Simule Orçamento'), findsOneWidget);
    expect(find.text('Meus Serviços'), findsOneWidget);
    expect(find.text('Fale Conosco'), findsOneWidget);
  });
}
