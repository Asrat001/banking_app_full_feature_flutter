// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferResponse _$TransferResponseFromJson(Map<String, dynamic> json) =>
    TransferResponse(
      message: json['message'] as String,
      amount: (json['amount'] as num).toDouble(),
      fromAccountNumber: json['fromAccountNumber'] as String,
      toAccountNumber: json['toAccountNumber'] as String,
    );

Map<String, dynamic> _$TransferResponseToJson(TransferResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'amount': instance.amount,
      'fromAccountNumber': instance.fromAccountNumber,
      'toAccountNumber': instance.toAccountNumber,
    };
