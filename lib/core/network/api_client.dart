import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:banking_app_challenge/core/constants/api_constants.dart';
import 'package:banking_app_challenge/core/errors/failures.dart';
import 'interceptors/AuthInterceptor.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static void Function()? onTokenExpired;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: ApiConstants.headers,
      ),
    );

    _dio.interceptors.add(ApiInterceptor(_storage));
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Failure _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timeout');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final rawMessage = error.response?.data?['message'] ?? 'Unknown error';

        String userFriendlyMessage = _parseErrorMessage(rawMessage);

        if (statusCode == 401) return AuthFailure(userFriendlyMessage);
        if (statusCode == 400) return ValidationFailure(userFriendlyMessage);
        return ServerFailure(userFriendlyMessage);

      case DioExceptionType.cancel:
        return const NetworkFailure('Request cancelled');
      case DioExceptionType.unknown:
        return const NetworkFailure('Network error occurred');
      default:
        return const NetworkFailure('Unknown network error');
    }
  }

  String _parseErrorMessage(String rawMessage) {
    if (rawMessage.contains('EMAIL') && rawMessage.contains('already exists')) {
      return 'This email address is already registered. Please use a different email.';
    } else if (rawMessage.contains('PHONE_NUMBER') &&
        rawMessage.contains('Unique index or primary key violation')) {
      return 'This phone number is already registered. Please use a different phone number.';
    } else if (rawMessage.contains('USERNAME') && rawMessage.contains('already exists')) {
      return 'This username is already taken. Please choose a different username.';
    } else if (rawMessage.contains('Unique index or primary key violation')) {
      return 'Some information you provided is already in use. Please try different values.';
    }
    return rawMessage;
  }
}


