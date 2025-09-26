import 'package:json_annotation/json_annotation.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  final String? message;
  final String? username;
  final int? userId;
  final String? accessToken;
  final String? refreshToken;
  final String? initialAccountNumber; // For registration response

  AuthResponseModel({
    this.message,
    this.username,
    this.userId,
    this.accessToken,
    this.refreshToken,
    this.initialAccountNumber,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}