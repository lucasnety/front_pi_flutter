import 'package:flutter/material.dart';
import '../services/user.service.dart';

const Color kPrimaryColor = Color(0xFFFFD72C);

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  final _userService = UserService();
  List<Map<String, dynamic>> clientes = [];

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  void _carregarUsuarios() async {
    try {
      List<dynamic> usuarios = await _userService.findAllUsers();
      setState(() {
        clientes = usuarios.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print("Erro ao carregar usuários: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Clientes"),
        backgroundColor: kPrimaryColor,
        elevation: 4,
        shadowColor: Colors.black.withAlpha(50),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: clientes.length,
        itemBuilder: (context, index) {
          final cliente = clientes[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cliente['nome'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Telefone: ${cliente['telefone']}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Email: ${cliente['email']}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
