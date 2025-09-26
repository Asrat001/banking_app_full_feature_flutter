
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../constants/api_constants.dart';
import '../api_client.dart';

class ApiInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  bool _isRefreshing = false;
  static bool _isHandlingTokenExpiry = false;

  ApiInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (kDebugMode) {
      developer.log('🔵 REQUEST: ${options.method} ${options.uri}');
      developer.log('Headers: ${options.headers}');
      developer.log('Data: ${options.data}');
    }

    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      developer.log('🟢 RESPONSE [${response.statusCode}]: ${response.requestOptions.uri}');
      developer.log('Response data: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      developer.log('🔴 ERROR [${error.response?.statusCode}]: ${error.requestOptions.uri}');
      developer.log('Error data: ${error.response?.data}');
      developer.log('Error message: ${error.message}');
    }

    if (error.requestOptions.path.contains(ApiConstants.refreshTokenEndpoint)) {
      handler.next(error);
      return;
    }

    if (error.response?.statusCode == 401 && !_isRefreshing) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        final options = error.requestOptions;
        final token = await _storage.read(key: 'access_token');
        options.headers['Authorization'] = 'Bearer $token';

        try {
          final response = await Dio().request(
            options.path,
            options: Options(
              method: options.method,
              headers: options.headers,
            ),
            data: options.data,
            queryParameters: options.queryParameters,
          );
          handler.resolve(response);
          return;
        } catch (e) {
          if (kDebugMode) developer.log('🔴 Retry after token refresh failed: $e');
        }
      } else {
        if (!_isHandlingTokenExpiry && ApiClient.onTokenExpired != null) {
          _isHandlingTokenExpiry = true;
          ApiClient.onTokenExpired!();
          Future.delayed(const Duration(seconds: 2), () => _isHandlingTokenExpiry = false);
        }
      }
    }

    handler.next(error);
  }

  Future<bool> _refreshToken() async {
    if (_isRefreshing) return false;

    _isRefreshing = true;
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final response = await Dio().post(
        ApiConstants.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
        options: Options(headers: ApiConstants.headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _storage.write(key: 'access_token', value: data['accessToken']);
        await _storage.write(key: 'refresh_token', value: data['refreshToken']);
        return true;
      }
    } catch (_) {
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
    } finally {
      _isRefreshing = false;
    }

    return false;
  }
}