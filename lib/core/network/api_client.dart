import 'dart:convert';

import 'package:http/http.dart' as http;

import '../storage/session_service.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:3000';

  final SessionService sessionService = SessionService();

  // ========================================
  // CREAR HEADERS
  // ========================================

  Future<Map<String, String>> _getHeaders() async {
    final token = await sessionService.getToken();

    final headers = <String, String>{'Content-Type': 'application/json'};

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ========================================
  // GET
  // ========================================

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');

    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);

    return _handleResponse(response);
  }

  // ========================================
  // POST
  // ========================================

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');

    final headers = await _getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // ========================================
  // MANEJAR RESPUESTA
  // ========================================

  dynamic _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception(data['message'] ?? 'Error ${response.statusCode}');
  }
}
