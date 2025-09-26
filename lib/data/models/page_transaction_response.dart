import 'package:json_annotation/json_annotation.dart';
import 'transaction_response.dart';

part 'page_transaction_response.g.dart';

@JsonSerializable()
class PageTransactionResponse {
  final int totalPages;
  final int totalElements;
  final int size;
  final List<TransactionResponse> content;
  final int number;
  final bool first;
  final bool last;
  final int numberOfElements;
  final bool empty;

  const PageTransactionResponse({
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.content,
    required this.number,
    required this.first,
    required this.last,
    required this.numberOfElements,
    required this.empty,
  });

  factory PageTransactionResponse.fromJson(Map<String, dynamic> json) =>
      _$PageTransactionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PageTransactionResponseToJson(this);
}