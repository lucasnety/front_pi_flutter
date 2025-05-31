import 'package:flutter/material.dart';
import 'usuarios_page.dart';
import 'orcamento_page.dart';
import 'criar_orcamento_page.dart';

class HomeAdmPage extends StatelessWidget {
  const HomeAdmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Administração"),
        backgroundColor: const Color.fromRGBO(255, 215, 44, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // 2 itens por linha
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1, // Proporção do item
          children: [
            _buildGridItem(
              context,
              title: 'Clientes',
              iconPath: 'assets/images/icon_usuarios.png',
              page: UsuariosPage(),
            ),
            _buildGridItem(
              context,
              title: 'Orçamentos',
              iconPath: 'assets/images/icon_orcamento.png',
              page: const OrcamentoPage(),
            ),
            _buildGridItem(
              context,
              title: 'Novo Orçamento',
              iconPath: 'assets/images/adicionar_icon.png',
              page: const CriarOrcamentoPage(),
            ),
          ],
        ),
      ),
    );
  }

  // MÉTODO PARA CONSTRUIR CADA ITEM DO GRID
  Widget _buildGridItem(
    BuildContext context, {
    required String title,
    required String iconPath,
    required Widget page,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(iconPath, height: 60, width: 60, fit: BoxFit.contain),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
