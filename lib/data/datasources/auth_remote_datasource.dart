import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String username, String password);
  Future<AuthResponseModel> register(Map<String, dynamic> userData);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponseModel> login(String username, String password) async {
    final response = await apiClient.post(
      ApiConstants.loginEndpoint,
      data: {
        'username': username,
        'passwordHash': password,
      },
    );

    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<AuthResponseModel> register(Map<String, dynamic> userData) async {
    try {
      print('🔄 AuthRemoteDataSource: Making API call to ${ApiConstants.registerEndpoint}');
      print('🔄 AuthRemoteDataSource: Request data: $userData');

      final response = await apiClient.post(
        ApiConstants.registerEndpoint,
        data: userData,
      );

      print('✅ AuthRemoteDataSource: Got API response: ${response.statusCode}');
      print('✅ AuthRemoteDataSource: Response data: ${response.data}');

      return AuthResponseModel.fromJson(response.data);
    } catch (e, stackTrace) {
      print('❌ AuthRemoteDataSource: Exception occurred: $e');
      print('❌ AuthRemoteDataSource: Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await apiClient.clearTokens();
  }
}