// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountModel _$AccountModelFromJson(Map<String, dynamic> json) => AccountModel(
      id: (json['id'] as num).toInt(),
      accountNumber: json['accountNumber'] as String,
      accountType: json['accountType'] as String,
      balance: (json['balance'] as num).toDouble(),
      userId: (json['userId'] as num).toInt(),
    );

Map<String, dynamic> _$AccountModelToJson(AccountModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountNumber': instance.accountNumber,
      'accountType': instance.accountType,
      'balance': instance.balance,
      'userId': instance.userId,
    };
