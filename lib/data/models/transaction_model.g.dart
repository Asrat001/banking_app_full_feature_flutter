// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: (json['id'] as num).toInt(),
      accountId: (json['accountId'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      direction: $enumDecode(_$TransactionDirectionEnumMap, json['direction']),
      description: json['description'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble(),
      toAccount: json['toAccount'] as String?,
      fromAccount: json['fromAccount'] as String?,
      relatedAccount: json['relatedAccount'] as String?,
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'amount': instance.amount,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'direction': _$TransactionDirectionEnumMap[instance.direction]!,
      'description': instance.description,
      'timestamp': instance.timestamp.toIso8601String(),
      'balanceAfter': instance.balanceAfter,
      'toAccount': instance.toAccount,
      'fromAccount': instance.fromAccount,
      'relatedAccount': instance.relatedAccount,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.FUND_TRANSFER: 'FUND_TRANSFER',
  TransactionType.TELLER_TRANSFER: 'TELLER_TRANSFER',
  TransactionType.ATM_WITHDRAWAL: 'ATM_WITHDRAWAL',
  TransactionType.TELLER_DEPOSIT: 'TELLER_DEPOSIT',
  TransactionType.BILL_PAYMENT: 'BILL_PAYMENT',
  TransactionType.ACCESS_FEE: 'ACCESS_FEE',
  TransactionType.PURCHASE: 'PURCHASE',
  TransactionType.REFUND: 'REFUND',
  TransactionType.INTEREST_EARNED: 'INTEREST_EARNED',
  TransactionType.LOAN_PAYMENT: 'LOAN_PAYMENT',
};

const _$TransactionDirectionEnumMap = {
  TransactionDirection.DEBIT: 'DEBIT',
  TransactionDirection.CREDIT: 'CREDIT',
};
