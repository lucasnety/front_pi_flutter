import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl = 'http://localhost:8000';
  final storage = FlutterSecureStorage();

  Future<bool> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: jsonEncode({'email': email, 'senha': senha}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Resposta do backend: $data');
      await storage.write(key: 'jwt', value: data['token']);
      await storage.write(key: 'admin', value: data['admin'].toString());
      await storage.write(key: 'user_id', value: data['user'].toString());
      return true;
    } else {
      return false;
    }
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'jwt');
  }

  Future<String?> getAdmin() async {
    return await storage.read(key: 'admin');
  }

  Future<void> logout() async {
    await storage.delete(key: 'jwt');
  }

  Future<String?> getUserId() async {
    return await storage.read(key: 'user_id');
  }
}
