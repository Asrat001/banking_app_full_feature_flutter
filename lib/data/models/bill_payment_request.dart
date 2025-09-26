import 'package:json_annotation/json_annotation.dart';

part 'bill_payment_request.g.dart';

@JsonSerializable()
class BillPaymentRequest {
  final String accountNumber;
  final String biller;
  final double amount;

  const BillPaymentRequest({
    required this.accountNumber,
    required this.biller,
    required this.amount,
  });

  factory BillPaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$BillPaymentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BillPaymentRequestToJson(this);
}