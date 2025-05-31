import 'package:flutter/material.dart';
import 'detalhes_page.dart';
import 'criar_orcamento_page.dart'; // Import da nova página
import '../services/orcamento_service.dart';

const Color kPrimaryColor = Color(0xFFFFD72C); // Cor principal para destaque

class OrcamentoPage extends StatefulWidget {
  const OrcamentoPage({super.key});

  @override
  _OrcamentoPageState createState() => _OrcamentoPageState();
}

class _OrcamentoPageState extends State<OrcamentoPage> {
  late Future<List<Map<String, dynamic>>> futureOrcamentos;

  final _orcamentoService = OrcamentoService();

  @override
  void initState() {
    super.initState();
    futureOrcamentos = getOrcamentos();
  }

  Future<List<Map<String, dynamic>>> getOrcamentos() async {
    List<dynamic> rawData = await _orcamentoService.findOrcamentoByView();
    return rawData
        .map((e) => e as Map<String, dynamic>)
        .toList(); // Ensuring correct type
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamentos'),
        backgroundColor: kPrimaryColor,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureOrcamentos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nenhum orçamento encontrado"));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final orcamento = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          orcamento['cliente'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(orcamento['descricao']),
                        trailing:
                            orcamento['status'] == 'Aceito'
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Progresso"),
                                    Text("${orcamento['progresso']}%"),
                                    SizedBox(
                                      width: 100,
                                      child: LinearProgressIndicator(
                                        value: orcamento['progresso'] / 100.0,
                                        backgroundColor: Colors.grey[300],
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              kPrimaryColor,
                                            ),
                                      ),
                                    ),
                                  ],
                                )
                                : Text('Status: ${orcamento['status']}'),
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => DetalhesPage(
                                      codigoOrcamento:
                                          orcamento['codigoOrcamento'],
                                    ),
                              ),
                            ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CriarOrcamentoPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
