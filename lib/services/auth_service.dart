import '../core/network/api_client.dart';
import '../models/user.dart';

class AuthService {
  final ApiClient apiClient = ApiClient();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await apiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });

    final user = User.fromJson(data['user']);
    final token = data['token'] as String;

    return {'user': user, 'token': token};
  }
}
