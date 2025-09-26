// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponseModel _$AuthResponseModelFromJson(Map<String, dynamic> json) =>
    AuthResponseModel(
      message: json['message'] as String?,
      username: json['username'] as String?,
      userId: (json['userId'] as num?)?.toInt(),
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      initialAccountNumber: json['initialAccountNumber'] as String?,
    );

Map<String, dynamic> _$AuthResponseModelToJson(AuthResponseModel instance) =>
    <String, dynamic>{
      'message': instance.message,
      'username': instance.username,
      'userId': instance.userId,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'initialAccountNumber': instance.initialAccountNumber,
    };
