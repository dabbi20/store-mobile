import '../core/network/api_client.dart';
import '../models/user.dart';

class UserService {
  final ApiClient apiClient = ApiClient();

  // ========================================
  // OBTENER PERFIL
  // ========================================

  Future<User> getMyProfile() async {
    final data = await apiClient.get('/users/me');

    return User.fromJson(data);
  }

  // ========================================
  // OBTENER ESTADÍSTICAS
  // ========================================

  Future<Map<String, dynamic>> getMyStats() async {
    final data = await apiClient.get('/users/me/stats');

    return Map<String, dynamic>.from(data);
  }

  // ========================================
  // ACTUALIZAR PERFIL
  // ========================================

  Future<User> updateMyProfile({
    required String username,
    required String email,
  }) async {
    final data = await apiClient.patch('/users/me', {
      'username': username,
      'email': email,
    });

    return User.fromJson(data['user']);
  }

  // ========================================
  // CAMBIAR CONTRASEÑA
  // ========================================

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await apiClient.patch('/users/me/password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
}
