import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curso_flutter/pages/home_adm.dart';

void main() {
  group('HomeAdmPage Integração', () {
    testWidgets('Verifica todos os itens do Grid', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeAdmPage()));
      await tester.pumpAndSettle();

      expect(find.text('Configurações'), findsOneWidget);
      expect(find.text('Clientes'), findsOneWidget);
      expect(find.text('Relatórios'), findsOneWidget);
      expect(find.text('Orçamentos'), findsOneWidget);
      expect(find.text('Novo Orçamento'), findsOneWidget);
    });

    testWidgets('Navega para Configurações', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeAdmPage()));
      await tester.tap(find.text('Configurações'));
      await tester.pumpAndSettle();

      expect(find.text('Configurações Page'), findsOneWidget);
    });

    testWidgets('Navega para Clientes', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeAdmPage()));
      await tester.tap(find.text('Clientes'));
      await tester.pumpAndSettle();

      expect(find.text('Clientes Page'), findsOneWidget);
    });

    testWidgets('Navega para Relatórios', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeAdmPage()));
      await tester.tap(find.text('Relatórios'));
      await tester.pumpAndSettle();

      expect(find.text('Relatórios Page'), findsOneWidget);
    });

    testWidgets('Navega para Orçamentos', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeAdmPage()));
      await tester.tap(find.text('Orçamentos'));
      await tester.pumpAndSettle();

      expect(find.text('Orçamentos Page'), findsOneWidget);
    });

    testWidgets('Navega para Novo Orçamento', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeAdmPage()));
      await tester.tap(find.text('Novo Orçamento'));
      await tester.pumpAndSettle();

      expect(find.text('Novo Orçamento Page'), findsOneWidget);
    });
  });
}
