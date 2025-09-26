import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/transaction_enums.dart';

part 'transaction_response.g.dart';

@JsonSerializable()
class TransactionResponse {
  final int id;
  final double amount;
  @JsonKey(unknownEnumValue: TransactionType.FUND_TRANSFER)
  final TransactionType type;
  @JsonKey(unknownEnumValue: TransactionDirection.DEBIT)
  final TransactionDirection direction;
  final DateTime timestamp;
  final String? description;
  final String? relatedAccount;
  final int accountId;

  const TransactionResponse({
    required this.id,
    required this.amount,
    required this.type,
    required this.direction,
    required this.timestamp,
    this.description,
    this.relatedAccount,
    required this.accountId,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) =>
      _$TransactionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionResponseToJson(this);
}