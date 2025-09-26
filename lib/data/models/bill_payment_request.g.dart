// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillPaymentRequest _$BillPaymentRequestFromJson(Map<String, dynamic> json) =>
    BillPaymentRequest(
      accountNumber: json['accountNumber'] as String,
      biller: json['biller'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$BillPaymentRequestToJson(BillPaymentRequest instance) =>
    <String, dynamic>{
      'accountNumber': instance.accountNumber,
      'biller': instance.biller,
      'amount': instance.amount,
    };
