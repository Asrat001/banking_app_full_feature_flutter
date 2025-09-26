import 'package:json_annotation/json_annotation.dart';

part 'account_model.g.dart';

@JsonSerializable()
class AccountModel {
  final int id;
  final String accountNumber;
  final String accountType;
  final double balance;
  final int userId;

  AccountModel({
    required this.id,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
    required this.userId,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) =>
      _$AccountModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountModelToJson(this);
}