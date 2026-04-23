import '../../../core/network/api_client.dart';
import '../../chat/domain/models.dart';

class AuthResult {
  final String token;
  final UserModel user;

  AuthResult({required this.token, required this.user});
}

class AuthRepository {
  final ApiClient api;

  AuthRepository(this.api);

  Future<AuthResult> login({required String identifier, required String password}) async {
    final isEmail = identifier.contains('@');
    final response = await api.post(
      '/api/auth/login',
      body: {
        if (isEmail) 'email' else 'phone': identifier,
        'password': password,
      },
    );

    return AuthResult(
      token: response.data['token'] as String,
      user: UserModel.fromJson(response.data['user']),
    );
  }

  Future<AuthResult> register({required String identifier, required String password, required String displayName}) async {
    final isEmail = identifier.contains('@');
    final response = await api.post(
      '/api/auth/register',
      body: {
        if (isEmail) 'email' else 'phone': identifier,
        'password': password,
        'displayName': displayName,
      },
    );

    return AuthResult(
      token: response.data['token'] as String,
      user: UserModel.fromJson(response.data['user']),
    );
  }
}
