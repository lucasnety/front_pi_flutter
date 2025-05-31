import 'package:flutter/material.dart';
import '../services/orcamento_service.dart';
import '../services/orcamento_itens_service.dart';
import '../services/user.service.dart';
import '../services/servicos_service.dart';

class DetalhesPage extends StatefulWidget {
  final int codigoOrcamento;

  const DetalhesPage({super.key, required this.codigoOrcamento});

  @override
  State<DetalhesPage> createState() => _DetalhesPageState();
}

class _DetalhesPageState extends State<DetalhesPage> {
  late Map<String, dynamic> orcamento;
  List<Map<String, dynamic>> itens = [];
  List<Map<String, dynamic>> servicosDisponiveis = [];
  final _servicoService = ServicoService();
  final _userService = UserService();
  final _orcamentosService = OrcamentoService();
  final _orcamento_itensService = OrcamentoItensService();

  @override
  void initState() {
    super.initState();
    _carregarOrcamento();
  }

  void _carregarOrcamento() async {
    orcamento = {
      'cliente': 'João da Silva',
      'progresso': 40,
      'status': 'Aceito',
    };

    try {
      List<dynamic> itens_orcamento =
          await _orcamento_itensService.findAllOrcamentoItens();
      setState(() {
        itens = itens_orcamento.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print("Erro ao carregar itens_orcamento: $e");
    }

    try {
      List<dynamic> servicos = await _servicoService.findAllServicosByView();
      setState(() {
        servicosDisponiveis = servicos.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print("Erro ao carregar servicos: $e");
    }
  }

  void _adicionarItem(Map<String, dynamic> item) {
    setState(() {
      itens.add(item);
    });
  }

  void _removerItem(int index) {
    setState(() {
      itens.removeAt(index);
    });
  }

  void _atualizarProgresso(double novoValor) {
    setState(() {
      orcamento['progresso'] = novoValor;
    });
  }

  double calcularTotal() {
    return itens.fold(0, (soma, item) {
      final dynamic valor = item['valor_unitario'];
      final int quantidade = item['quantidade'] as int;

      final double valorUnitario =
          valor is String ? double.tryParse(valor) ?? 0 : valor.toDouble();

      return soma + valorUnitario * quantidade;
    });
  }

  void _mostrarDialogoAdicionarItem() {
    String? servicoSelecionado;
    int quantidade = 1;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Adicionar Item'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  hint: const Text('Selecione um serviço'),
                  items:
                      servicosDisponiveis.map((servico) {
                        return DropdownMenuItem(
                          value: servico['nome'] as String,
                          child: Text(servico['nome'] as String),
                        );
                      }).toList(),
                  onChanged: (value) {
                    servicoSelecionado = value;
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Quantidade (metros)',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    quantidade = int.tryParse(value) ?? 1;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (servicoSelecionado != null) {
                    if (itens.any(
                      (item) => item['nome'] == servicoSelecionado,
                    )) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Item já adicionado.')),
                      );
                      return;
                    }
                    final servico = servicosDisponiveis.firstWhere(
                      (s) => s['nome'] == servicoSelecionado,
                    );
                    _adicionarItem({
                      'id': itens.length + 1,
                      'nome': servico['nome'],
                      'valor_unitario': double.parse(
                        servico['valor_unitario'].toString(),
                      ),
                      'quantidade': quantidade,
                    });
                  }
                  Navigator.pop(context);
                },
                child: const Text('Adicionar'),
              ),
            ],
          ),
    );
  }

  void _alterarQuantidade(int index, int novaQuantidade) {
    setState(() {
      itens[index]['quantidade'] = novaQuantidade;
    });
  }

  void _salvarAlteracoes() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirmar'),
            content: const Text('Tem certeza que deseja salvar as alterações?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  // Aqui você faria a chamada ao backend para atualizar os dados no banco
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Alterações salvas com sucesso!'),
                    ),
                  );
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Orçamento'),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${orcamento['cliente']}'),
            const SizedBox(height: 16),
            const Text(
              'Itens do Orçamento:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: itens.length,
                itemBuilder: (_, index) {
                  final item = itens[index];
                  return ListTile(
                    title: Text(item['nome'] as String),
                    subtitle: Text(
                      'R\$ ${(item['valor_unitario'] as double).toStringAsFixed(2)} x ${item['quantidade']} metros',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          color: Colors.amber,
                          onPressed: () {
                            int novaQuantidade = item['quantidade'];
                            showDialog(
                              context: context,
                              builder:
                                  (_) => AlertDialog(
                                    title: const Text('Alterar Quantidade'),
                                    content: TextField(
                                      controller: TextEditingController(
                                        text: novaQuantidade.toString(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        novaQuantidade =
                                            int.tryParse(value) ??
                                            novaQuantidade;
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Quantidade (metros)',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _alterarQuantidade(
                                            index,
                                            novaQuantidade,
                                          );
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Alterar'),
                                      ),
                                    ],
                                  ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.amber,
                          onPressed: () => _removerItem(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Text(
              'Total: R\$ ${calcularTotal().toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey[800],
              ),
              onPressed: _mostrarDialogoAdicionarItem,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Item'),
            ),
            const SizedBox(height: 16),
            Text('Progresso: ${orcamento['progresso'].toInt()}%'),
            Slider(
              value: (orcamento['progresso'] as num).toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              label: '${orcamento['progresso']}%',
              onChanged:
                  (orcamento['status'] == 'Aceito')
                      ? _atualizarProgresso
                      : null,
              activeColor: Colors.amber,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey[800],
              ),
              onPressed: _salvarAlteracoes,
              child: const Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
