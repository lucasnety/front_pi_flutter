import 'package:curso_flutter/services/servicos_service.dart';
import 'package:flutter/material.dart';
import '../services/orcamento_service.dart';
import '../services/orcamento_itens_service.dart';
import '../services/user.service.dart';
import '../models/user_model.dart';

class CriarOrcamentoPage extends StatefulWidget {
  const CriarOrcamentoPage({super.key});

  @override
  State<CriarOrcamentoPage> createState() => _CriarOrcamentoPageState();
}

class _CriarOrcamentoPageState extends State<CriarOrcamentoPage> {
  // Variáveis para armazenar o cliente selecionado
  String? clienteSelecionadoNome;
  int? clienteSelecionadoCodigo;
  final _servicoService = ServicoService();
  final _userService = UserService();
  final _orcamentosService = OrcamentoService();
  final _orcamento_itensService = OrcamentoItensService();
  List<Map<String, dynamic>> clientes = [];
  List<Map<String, dynamic>> servicosDisponiveis = [];

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
    _carregarServicos();
  }

  // Lista simulada de clientes
  void _carregarUsuarios() async {
    try {
      List<dynamic> usuarios = await _userService.findUsersByView();
      setState(() {
        clientes = usuarios.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print("Erro ao carregar servicos: $e");
    }
  }

  // Controller para o campo de descrição do serviço
  TextEditingController descricaoController = TextEditingController();

  // Lista de itens adicionados ao orçamento
  List<Map<String, dynamic>> itens = [];

  void _carregarServicos() async {
    try {
      List<dynamic> servicos = await _servicoService.findAllServicosByView();
      setState(() {
        servicosDisponiveis = servicos.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print("Erro ao carregar servicos: $e");
    }
  }

  // Função para abrir modal e permitir que usuário selecione cliente
  //carregada por uma chamada HTTP (API)
  void _abrirListaClientes() async {
    final resultado = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (_) {
        return ListView.separated(
          itemCount: clientes.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, index) {
            final cliente = clientes[index];
            return ListTile(
              title: Text('${cliente['codigo']} - ${cliente['nome']}'),
              onTap: () {
                Navigator.pop(context, cliente);
              },
            );
          },
        );
      },
    );

    if (resultado != null) {
      setState(() {
        clienteSelecionadoCodigo = resultado['codigo'];
        clienteSelecionadoNome = resultado['nome'];
      });
    }
  }

  // Função para adicionar um item ao orçamento
  // Exibe diálogo com dropdown para escolher serviço e campo para quantidade
  void _adicionarItem() {
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
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  if (servicoSelecionado != null) {
                    // Prevent adding duplicate services by name
                    if (itens.any(
                      (item) => item['nome'] == servicoSelecionado,
                    )) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Item já adicionado.')),
                      );
                      return;
                    }

                    // Find the selected service by name
                    final servico = servicosDisponiveis.firstWhere(
                      (s) => s['nome'] == servicoSelecionado,
                    );
                    print(
                      'valor_unitario raw: ${servico['valor_unitario']} (${servico['valor_unitario']?.runtimeType})',
                    );

                    // Get index of the service and use it as id_servico (starting at 1)
                    final servicoIndex = servicosDisponiveis.indexOf(servico);
                    final servicoId = servicoIndex + 1;

                    final novoItem = {
                      'id_servico': servicoId,
                      'nome': servico['nome'],
                      'valor_unitario':
                          servico['valor_unitario'] != null
                              ? double.parse(servico['valor_unitario'])
                              : 0.0,
                      'quantidade': quantidade,
                    };

                    setState(() {
                      itens.add(novoItem);
                    });

                    try {
                      await _orcamento_itensService.createOrcamentoIten(
                        novoItem,
                      );
                      print('Item saved successfully.');
                    } catch (e) {
                      print('Error saving item: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao salvar item: $e')),
                      );
                    }
                  }
                  Navigator.pop(context);
                },
                child: const Text('Adicionar'),
              ),
            ],
          ),
    );
  }

  // Remove um item da lista pelo índice
  void _removerItem(int index) {
    setState(() {
      itens.removeAt(index);
    });
  }

  // Altera a quantidade de um item da lista
  void _alterarQuantidade(int index, int novaQuantidade) {
    setState(() {
      itens[index]['quantidade'] = novaQuantidade;
    });
  }

  // Calcula o valor total do orçamento somando preço * quantidade dos itens
  double calcularTotal() {
    return itens.fold(
      0,
      (soma, item) =>
          soma +
          (item['valor_unitario'] as double) * (item['quantidade'] as int),
    );
  }

  void _salvarOrcamento() async {
    if (clienteSelecionadoNome == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um cliente')),
      );
      return;
    }

    if (descricaoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Descrição do serviço não pode estar vazia'),
        ),
      );
      return;
    }

    if (itens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um item')),
      );
      return;
    }

    final orcamentoData = {
      'descricao': descricaoController.text.trim(),
      'id_cliente': clienteSelecionadoCodigo,
      'itens':
          itens
              .map(
                (item) => {
                  'id_servico': item['id_servico'],
                  'quantidade': item['quantidade'],
                  'valor_unitario': item['valor_unitario'],
                },
              )
              .toList(),
    };

    try {
      await _orcamentosService.createOrcamento(orcamentoData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Orçamento salvo com sucesso')),
      );

      // Limpar campos após sucesso
      setState(() {
        descricaoController.clear();
        clienteSelecionadoNome = null;
        clienteSelecionadoCodigo = null;
        itens.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar orçamento: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Orçamento'),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cliente:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _abrirListaClientes,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  clienteSelecionadoNome != null
                      ? '${clienteSelecionadoCodigo} - $clienteSelecionadoNome'
                      : 'Selecione um cliente',
                  style: TextStyle(
                    color:
                        clienteSelecionadoNome != null
                            ? Colors.black
                            : Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Descrição do Serviço:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(
                hintText: 'Descrição do serviço',
              ),
              maxLines: null,
            ),
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
                                        onPressed: () => Navigator.pop(context),
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
              onPressed: _adicionarItem,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Item'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey[800],
              ),
              onPressed: _salvarOrcamento,
              child: const Text('Salvar Orçamento'),
            ),
          ],
        ),
      ),
    );
  }
}
