import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/transaction_enums.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel {
  final int id;
  final int accountId;
  final double amount;
  final TransactionType type;
  final TransactionDirection direction;
  final String? description;
  final DateTime timestamp;
  final double? balanceAfter;
  final String? toAccount;
  final String? fromAccount;
  final String? relatedAccount;

  TransactionModel({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.type,
    required this.direction,
    this.description,
    required this.timestamp,
    this.balanceAfter,
    this.toAccount,
    this.fromAccount,
    this.relatedAccount,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);
}