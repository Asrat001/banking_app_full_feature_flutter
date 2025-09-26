// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_account_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateAccountRequest _$CreateAccountRequestFromJson(
        Map<String, dynamic> json) =>
    CreateAccountRequest(
      accountType: json['accountType'] as String,
      initialBalance: (json['initialBalance'] as num).toDouble(),
    );

Map<String, dynamic> _$CreateAccountRequestToJson(
        CreateAccountRequest instance) =>
    <String, dynamic>{
      'accountType': instance.accountType,
      'initialBalance': instance.initialBalance,
    };

AccountResponse _$AccountResponseFromJson(Map<String, dynamic> json) =>
    AccountResponse(
      id: (json['id'] as num).toInt(),
      accountNumber: json['accountNumber'] as String,
      balance: (json['balance'] as num).toDouble(),
      userId: (json['userId'] as num).toInt(),
      accountType: json['accountType'] as String,
    );

Map<String, dynamic> _$AccountResponseToJson(AccountResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountNumber': instance.accountNumber,
      'balance': instance.balance,
      'userId': instance.userId,
      'accountType': instance.accountType,
    };
