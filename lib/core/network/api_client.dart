import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../storage/session_service.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:3000';

  final SessionService sessionService = SessionService();

  // ========================================
  // CREAR HEADERS
  // ========================================

  Future<Map<String, String>> _getHeaders({bool authenticated = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    // ========================================
    // AGREGAR JWT
    // ========================================

    if (authenticated) {
      final token = await sessionService.getToken();

      debugPrint(
        'TOKEN EN API CLIENT: '
        '${token != null ? "encontrado" : "null"}',
      );

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ========================================
  // GET
  // ========================================

  Future<dynamic> get(String endpoint, {bool authenticated = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');

    final headers = await _getHeaders(authenticated: authenticated);

    final response = await http.get(url, headers: headers);

    return _handleResponse(response);
  }

  // ========================================
  // POST
  // ========================================

  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool authenticated = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    final headers = await _getHeaders(authenticated: authenticated);

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // ========================================
  // PATCH
  // ========================================

  Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool authenticated = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    final headers = await _getHeaders(authenticated: authenticated);

    final response = await http.patch(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // ========================================
  // DELETE
  // ========================================

  Future<dynamic> delete(String endpoint, {bool authenticated = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');

    final headers = await _getHeaders(authenticated: authenticated);

    final response = await http.delete(url, headers: headers);

    return _handleResponse(response);
  }

  // ========================================
  // MANEJAR RESPUESTA
  // ========================================

  dynamic _handleResponse(http.Response response) {
    dynamic data;

    if (response.body.isNotEmpty) {
      data = jsonDecode(response.body);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      throw Exception(data['message'] ?? 'Error ${response.statusCode}');
    }

    throw Exception('Error ${response.statusCode}');
  }
}
