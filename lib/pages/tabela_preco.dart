import 'package:flutter/material.dart';
import '../services/servicos_service.dart';
import '../models/servico_model.dart';

class TabelaPrecoPage extends StatefulWidget {
  const TabelaPrecoPage({super.key});

  @override
  State<TabelaPrecoPage> createState() => _TabelaPrecoPageState();
}

class _TabelaPrecoPageState extends State<TabelaPrecoPage> {
  final _servicoService = ServicoService();

  Future<List<Servico>> obterServicos() {
    return _servicoService.findAllServicosByViewList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabela de Preços'),
        backgroundColor: const Color(0xFFFFD72C),
      ),
      body: FutureBuilder<List<Servico>>(
        future: obterServicos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os preços.'));
          }

          final servicos = snapshot.data ?? [];

          return ListView.separated(
            itemCount: servicos.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final servico = servicos[index];
              return ListTile(
                title: Text(
                  servico.nome,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  'R\$ ${servico.valor_unitario.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
