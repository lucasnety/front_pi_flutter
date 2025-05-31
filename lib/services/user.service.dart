import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserService {
  final String baseUrl = "http://localhost:8000";

  Future<Map<String, dynamic>> findUserById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/user/$id"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Usuário não encontrado");
    }
  }

  Future<List<dynamic>> findAllUsers() async {
    final response = await http.get(Uri.parse("$baseUrl/users"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("falha ao buscar usuários");
    }
  }

  Future<List<dynamic>> findUsersByView() async {
    final response = await http.get(Uri.parse("$baseUrl/view_users"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("falha ao buscar usuários");
    }
  }

  Future<void> createUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse("$baseUrl/user"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userData),
    );

    if (response.statusCode != 201) {
      throw Exception("falha ao criar usuário");
    }
  }

  Future<void> updateUser(String id, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse("$baseUrl/user/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userData),
    );

    if (response.statusCode != 200) {
      throw Exception("falha ao atualizar usuário");
    }
  }

  Future<void> deleteUser(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/user/$id"));

    if (response.statusCode != 200) {
      throw Exception("falha ao deletar usuário");
    }
  }

  Future<List<User>> findAllUsersDart() async {
    final response = await http.get(Uri.parse("$baseUrl/users"));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception("Erro ${response.statusCode}: ${response.body}");
    }
  }
}
