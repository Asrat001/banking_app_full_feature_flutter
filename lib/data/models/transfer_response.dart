import 'package:json_annotation/json_annotation.dart';

part 'transfer_response.g.dart';

@JsonSerializable()
class TransferResponse {
  final String message;
  final double amount;
  final String fromAccountNumber;
  final String toAccountNumber;

  const TransferResponse({
    required this.message,
    required this.amount,
    required this.fromAccountNumber,
    required this.toAccountNumber,
  });

  factory TransferResponse.fromJson(Map<String, dynamic> json) =>
      _$TransferResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TransferResponseToJson(this);
}