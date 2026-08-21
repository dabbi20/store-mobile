import '../core/network/api_client.dart';
import '../core/storage/session_service.dart';
import '../models/user.dart';

class AuthService {
  final ApiClient apiClient = ApiClient();
  final SessionService sessionService = SessionService();

  // ========================================
  // LOGIN
  // ========================================

  Future<User> login(String email, String password) async {
    final data = await apiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });

    final user = User.fromJson(data['user']);

    final token = data['token'] as String;

    // ========================================
    // GUARDAR JWT
    // ========================================

    await sessionService.saveToken(token);

    return user;
  }

  // ========================================
  // LOGOUT
  // ========================================

  Future<void> logout() async {
    await sessionService.removeToken();
  }

  // ========================================
  // COMPROBAR SESIÓN LOCAL
  // ========================================

  Future<bool> hasSession() async {
    return sessionService.hasToken();
  }
}
