import 'package:json_annotation/json_annotation.dart';

part 'create_account_request.g.dart';

enum AccountType {
  @JsonValue('CHECKING')
  checking,
  @JsonValue('SAVINGS')
  savings,
  @JsonValue('MONEY_MARKET')
  moneyMarket,
  @JsonValue('INDIVIDUAL_RETIREMENT_ACCOUNT')
  individualRetirementAccount,
  @JsonValue('FIXED_TIME_DEPOSIT')
  fixedTimeDeposit,
  @JsonValue('SPECIAL_BLOCKED_ACCOUNT')
  specialBlockedAccount,
}

@JsonSerializable()
class CreateAccountRequest {
  final String accountType;
  final double initialBalance;

  CreateAccountRequest({
    required this.accountType,
    required this.initialBalance,
  });

  factory CreateAccountRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAccountRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateAccountRequestToJson(this);
}

@JsonSerializable()
class AccountResponse {
  final int id;
  final String accountNumber;
  final double balance;
  final int userId;
  final String accountType;

  AccountResponse({
    required this.id,
    required this.accountNumber,
    required this.balance,
    required this.userId,
    required this.accountType,
  });

  factory AccountResponse.fromJson(Map<String, dynamic> json) =>
      _$AccountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AccountResponseToJson(this);
}