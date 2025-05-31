import 'package:flutter/material.dart';
import '../services/servicos_service.dart';
import '../services/auth_service.dart';
import '../models/orcamento_itemservico_model.dart';
import '../services/orcamento_service.dart';
import '../services/orcamento_itens_service.dart';

class MeusServicosPage extends StatefulWidget {
  const MeusServicosPage({super.key});

  @override
  _MeusServicosPageState createState() => _MeusServicosPageState();
}

class _MeusServicosPageState extends State<MeusServicosPage> {
  final _servicoService = ServicoService();
  final _orcamentosService = OrcamentoService();
  final _orcamento_itensService = OrcamentoItensService();
  final _authService = AuthService();

  List<Orcamento> orcamentos = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    carregarOrcamentos();
  }

  Future<void> carregarOrcamentos() async {
    try {
      final userIdString = await _authService.getUserId();

      print('userIdString recuperado: $userIdString');

      if (userIdString == null) {
        throw Exception("ID do cliente não encontrado");
      }

      final int? id_cliente = int.tryParse(userIdString);
      if (id_cliente == null) {
        throw Exception("ID do cliente inválido");
      }

      final resultado = await _orcamentosService.findMeuOrcamentoByView(
        id_cliente,
      );

      print('resultado: $resultado');

      setState(() {
        orcamentos = resultado;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Erro ao carregar orçamentos: $e";
        isLoading = false;
      });
    }
  }

  String formatarValor(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Serviços'),
        backgroundColor: const Color(0xFFFFD72C), // amarelo igual seu exemplo
      ),
      body:
          orcamentos.isEmpty
              ? const Center(
                child: Text(
                  'Você não possui orçamentos ou serviços contratados no momento.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: orcamentos.length,
                itemBuilder: (context, i) {
                  final orc = orcamentos[i];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        orc.descricao,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      // Nenhum conteúdo dentro do ExpansionTile, pois descrição e itens foram removidos
                    ),
                  );
                },
              ),
    );
  }
}
