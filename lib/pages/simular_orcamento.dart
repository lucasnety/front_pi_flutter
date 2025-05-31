import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // PARA COPIAR PARA ÁREA DE TRANSFERÊNCIA
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SimularOrcamento extends StatefulWidget {
  const SimularOrcamento({super.key});

  @override
  State<SimularOrcamento> createState() => _SimularOrcamentoState();
}

class _SimularOrcamentoState extends State<SimularOrcamento> {
  final List<Servico> servicos = [
    Servico(
      'Gesso liso (Parede Rebocada)',
      'Aplicação de gesso liso sobre parede rebocada',
      18.00,
    ),
    Servico(
      'Gesso liso (Alvenaria 25)',
      'Aplicação de gesso liso sobre alvenaria',
      25.00,
    ),
    Servico(
      'Gesso liso (Chapisco)',
      'Aplicação de gesso liso sobre parede com chapisco',
      30.00,
    ),
    Servico('Drywall', 'Instalação de placas de drywall', 75.00),
    Servico(
      'Parede de Drywall',
      'Montagem de parede com estrutura em drywall',
      120.00,
    ),
    Servico('Moldura (7 cm)', 'Instalação de moldura de 7 cm', 10.00),
    Servico('Moldura (10 cm)', 'Instalação de moldura de 10 cm', 13.00),
    Servico('Moldura (12 cm)', 'Instalação de moldura de 12 cm', 13.00),
  ];

  final Map<Servico, int> quantidades = {};
  final Map<Servico, TextEditingController> controllers = {};

  double get total {
    double sum = 0;
    quantidades.forEach((servico, qtd) {
      sum += servico.valorUnitario * qtd;
    });
    return sum;
  }

  String montaResumo() {
    StringBuffer buffer = StringBuffer();
    buffer.writeln('Orçamento Simulado');
    buffer.writeln('------------------------');
    quantidades.forEach((servico, qtd) {
      if (qtd > 0) {
        buffer.writeln(
          '${servico.nome} x $qtd = R\$ ${(servico.valorUnitario * qtd).toStringAsFixed(2)}',
        );
      }
    });
    buffer.writeln('------------------------');
    buffer.writeln('Total: R\$ ${total.toStringAsFixed(2)}');
    return buffer.toString();
  }

  Future<void> gerarPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Orçamento Simulado',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Divider(),
              ...quantidades.entries.where((e) => e.value > 0).map((e) {
                final servico = e.key;
                final qtd = e.value;
                return pw.Text(
                  '${servico.nome} x $qtd = R\$ ${(servico.valorUnitario * qtd).toStringAsFixed(2)}',
                );
              }),
              pw.Divider(),
              pw.Text(
                'Total: R\$ ${total.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );

    if (!mounted) return;
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simular Orçamento'),
        backgroundColor: const Color(0xFFFFD72C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: servicos.length,
                itemBuilder: (context, index) {
                  final servico = servicos[index];
                  final quantidade = quantidades[servico] ?? 0;

                  if (!controllers.containsKey(servico)) {
                    controllers[servico] = TextEditingController(
                      text: quantidade.toString(),
                    );
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            servico.nome,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            servico.descricao,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'R\$ ${servico.valorUnitario.toStringAsFixed(2)} / unidade',
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Quantidade:'),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed:
                                        quantidade > 0
                                            ? () {
                                              setState(() {
                                                quantidades[servico] =
                                                    quantidade - 1;
                                                controllers[servico]?.text =
                                                    (quantidades[servico] ?? 0)
                                                        .toString();
                                                if (quantidades[servico] == 0) {
                                                  quantidades.remove(servico);
                                                }
                                              });
                                            }
                                            : null,
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: TextFormField(
                                      controller: controllers[servico],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 0,
                                        ),
                                        isDense: true,
                                      ),
                                      onChanged: (value) {
                                        final intQtd = int.tryParse(value) ?? 0;
                                        setState(() {
                                          if (intQtd <= 0) {
                                            quantidades.remove(servico);
                                          } else {
                                            quantidades[servico] = intQtd;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        quantidades[servico] = quantidade + 1;
                                        controllers[servico]?.text =
                                            (quantidade + 1).toString();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: R\$ ${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share),
                        tooltip: 'Compartilhar orçamento',
                        onPressed: () {
                          final texto = montaResumo();
                          Clipboard.setData(ClipboardData(text: texto));
                          Share.share(texto, subject: 'Orçamento Simulado');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf),
                        tooltip: 'Exportar orçamento em PDF',
                        onPressed: total > 0 ? gerarPdf : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Servico {
  final String nome;
  final String descricao;
  final double valorUnitario;

  Servico(this.nome, this.descricao, this.valorUnitario);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Servico &&
          runtimeType == other.runtimeType &&
          nome == other.nome &&
          descricao == other.descricao &&
          valorUnitario == other.valorUnitario;

  @override
  int get hashCode =>
      nome.hashCode ^ descricao.hashCode ^ valorUnitario.hashCode;
}
