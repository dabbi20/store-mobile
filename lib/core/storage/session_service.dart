import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _tokenKey = 'auth_token';

  // ========================================
  // GUARDAR TOKEN
  // ========================================

  Future<void> saveToken(String token) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_tokenKey, token);
  }

  // ========================================
  // OBTENER TOKEN
  // ========================================

  Future<String?> getToken() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString(_tokenKey);
  }

  // ========================================
  // COMPROBAR SI EXISTE SESIÓN
  // ========================================

  Future<bool> hasToken() async {
    final token = await getToken();

    return token != null && token.isNotEmpty;
  }

  // ========================================
  // ELIMINAR TOKEN
  // ========================================

  Future<void> removeToken() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_tokenKey);
  }
}
