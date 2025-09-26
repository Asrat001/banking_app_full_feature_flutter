// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_payment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillPaymentResponse _$BillPaymentResponseFromJson(Map<String, dynamic> json) =>
    BillPaymentResponse(
      message: json['message'] as String,
      amount: (json['amount'] as num).toDouble(),
      accountNumber: json['accountNumber'] as String,
      biller: json['biller'] as String,
    );

Map<String, dynamic> _$BillPaymentResponseToJson(
        BillPaymentResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'amount': instance.amount,
      'accountNumber': instance.accountNumber,
      'biller': instance.biller,
    };
