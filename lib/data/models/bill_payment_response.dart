import 'package:json_annotation/json_annotation.dart';

part 'bill_payment_response.g.dart';

@JsonSerializable()
class BillPaymentResponse {
  final String message;
  final double amount;
  final String accountNumber;
  final String biller;

  const BillPaymentResponse({
    required this.message,
    required this.amount,
    required this.accountNumber,
    required this.biller,
  });

  factory BillPaymentResponse.fromJson(Map<String, dynamic> json) =>
      _$BillPaymentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BillPaymentResponseToJson(this);
}