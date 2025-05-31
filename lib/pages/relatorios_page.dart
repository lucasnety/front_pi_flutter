import 'package:flutter/material.dart';

class RelatoriosPage extends StatelessWidget {
  const RelatoriosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Relatórios"),
        backgroundColor: const Color(0xFFFFD72C),
      ),
      body: Center(
        child: const Text(
          "Página de Relatórios",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
