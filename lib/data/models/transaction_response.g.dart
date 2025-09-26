// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionResponse _$TransactionResponseFromJson(Map<String, dynamic> json) =>
    TransactionResponse(
      id: (json['id'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      type: $enumDecode(_$TransactionTypeEnumMap, json['type'],
          unknownValue: TransactionType.FUND_TRANSFER),
      direction: $enumDecode(_$TransactionDirectionEnumMap, json['direction'],
          unknownValue: TransactionDirection.DEBIT),
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String?,
      relatedAccount: json['relatedAccount'] as String?,
      accountId: (json['accountId'] as num).toInt(),
    );

Map<String, dynamic> _$TransactionResponseToJson(
        TransactionResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'direction': _$TransactionDirectionEnumMap[instance.direction]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'description': instance.description,
      'relatedAccount': instance.relatedAccount,
      'accountId': instance.accountId,
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
