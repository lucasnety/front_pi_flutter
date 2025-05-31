import 'package:flutter/material.dart';

class ConfiguracoesPage extends StatelessWidget {
  const ConfiguracoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações"),
        backgroundColor: const Color(0xFFFFD72C),
      ),
      body: Center(
        child: const Text(
          "Página de Configurações",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
