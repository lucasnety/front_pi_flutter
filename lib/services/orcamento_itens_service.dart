import 'dart:convert';
import 'package:http/http.dart' as http;

class OrcamentoItensService {
  final String baseUrl = "http://localhost:8000";

  Future<void> createOrcamentoIten(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/orcamento_iten"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception("falha ao criar item de orçamento");
    }
  }

  Future<Map<String, dynamic>> findOrcamentoItenById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/orcamento_iten/$id"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Item de orçamento não encontrado");
    }
  }

  Future<List<dynamic>> findAllOrcamentoItens() async {
    final response = await http.get(Uri.parse("$baseUrl/orcamento_itens"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("falha ao buscar itens de orçamento");
    }
  }

  Future<void> updateOrcamentoIten(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("$baseUrl/orcamento_iten/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception("falha ao atualizar item de orçamento");
    }
  }

  Future<void> deleteOrcamentoIten(String id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/orcamento_iten/$id"),
    );

    if (response.statusCode != 200) {
      throw Exception("falha ao deletar item de orçamento");
    }
  }
}
