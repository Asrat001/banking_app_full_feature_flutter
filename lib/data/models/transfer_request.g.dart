// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferRequest _$TransferRequestFromJson(Map<String, dynamic> json) =>
    TransferRequest(
      fromAccountNumber: json['fromAccountNumber'] as String,
      toAccountNumber: json['toAccountNumber'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$TransferRequestToJson(TransferRequest instance) =>
    <String, dynamic>{
      'fromAccountNumber': instance.fromAccountNumber,
      'toAccountNumber': instance.toAccountNumber,
      'amount': instance.amount,
    };
