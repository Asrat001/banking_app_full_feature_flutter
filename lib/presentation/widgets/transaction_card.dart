import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_enums.dart';
import '../bloc/account/account_bloc.dart';
import '../pages/transaction_detail_page.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.transaction,
  });

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    String icon;
    String title;

    switch (transaction.type) {
      case TransactionType.FUND_TRANSFER:
        icon = "assets/transfer_icon.svg";
        title = 'Fund Transfer';
        break;
      case TransactionType.BILL_PAYMENT:
        icon = "assets/doc_icon.svg";
        title = 'Bill Payment';
        break;
      case TransactionType.GROCERY:
        icon = "assets/cart_icon.svg";
        title = 'Grocery';
        break;
      case TransactionType.CARD_PAYMENT:
        icon = "assets/card_icon.svg";
        title = 'Card Payment';
        break;
      case TransactionType.PURCHASE:
        icon = "assets/cart_icon.svg";
        title = 'Purchase';
        break;
      case TransactionType.INTEREST_EARNED:
        icon = "assets/transfer_icon.svg";
        title = 'Interest';
        break;
      default:
        icon = "transfer_icon.svg";
        title = transaction.type.displayName;
    }



    final isDebit = transaction.direction.isDebit;
    final amountPrefix = isDebit ? '-' : '';
    final amount =
        '$amountPrefix \$ ${transaction.amount.toStringAsFixed(2)}';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(
                  value: context.read<AccountBloc>(),
                ),
              ],
              child: TransactionDetailPage(transaction: transaction),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey)),
              child: SvgPicture.asset(
                icon,
                height: 22,
                width: 22,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}