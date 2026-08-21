import '../core/network/api_client.dart';
import '../models/user.dart';

class UserService {
  final ApiClient apiClient = ApiClient();

  // ========================================
  // OBTENER PERFIL DEL USUARIO AUTENTICADO
  // ========================================

  Future<User> getMyProfile() async {
    final data = await apiClient.get('/users/me');

    return User.fromJson(data);
  }
}
