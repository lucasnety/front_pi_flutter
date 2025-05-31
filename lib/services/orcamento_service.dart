import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/orcamento_itemservico_model.dart';

class OrcamentoService {
  final String baseUrl = "http://localhost:8000";

  Future<Map<String, dynamic>> findOrcamentoById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/orcamento/$id"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("orçamento não encontrado");
    }
  }

  Future<List<dynamic>> findAllOrcamentos() async {
    final response = await http.get(Uri.parse("$baseUrl/orcamentos"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("orçamento não encontrado");
    }
  }

  Future<List<dynamic>> findOrcamentoByView() async {
    final response = await http.get(Uri.parse("$baseUrl/view_orcamentos"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("orçamentos não encontrado");
    }
  }

  Future<List<dynamic>> findOrcamentosByView() async {
    final response = await http.get(Uri.parse("$baseUrl/view_all_orcamentos"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("orçamentos não encontrado");
    }
  }

  Future<List<Orcamento>> findMeuOrcamentoByView(int id_cliente) async {
    final url = "$baseUrl/view_orcamentos_meu_servicos/$id_cliente";
    print('Chamando URL: $url');

    final response = await http.get(
      Uri.parse("$baseUrl/view_orcamentos_meu_servicos/$id_cliente"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("orçamentos não encontrado");
    }
  }

  Future<void> createOrcamento(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/orcamento"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception("falha ao criar orçamento");
    }
  }

  Future<void> updateOrcamento(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("$baseUrl/orcamento/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception("falha ao atualizar orçamento");
    }
  }

  Future<void> deleteOrcamento(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/orcamento/$id"));

    if (response.statusCode != 200) {
      throw Exception("falha ao deletar orçamento");
    }
  }
}
