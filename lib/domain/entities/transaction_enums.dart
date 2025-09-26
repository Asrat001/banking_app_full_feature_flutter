// ignore_for_file: constant_identifier_names

enum TransactionType {
  FUND_TRANSFER,
  TELLER_TRANSFER,
  ATM_WITHDRAWAL,
  TELLER_DEPOSIT,
  BILL_PAYMENT,
  ACCESS_FEE,
  PURCHASE,
  REFUND,
  INTEREST_EARNED,
  LOAN_PAYMENT,
  SALARY,
  GROCERY,
  CARD_PAYMENT,
}

enum TransactionDirection {
  DEBIT,
  CREDIT,
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.FUND_TRANSFER:
        return 'Fund Transfer';
      case TransactionType.TELLER_TRANSFER:
        return 'Teller Transfer';
      case TransactionType.ATM_WITHDRAWAL:
        return 'ATM Withdrawal';
      case TransactionType.TELLER_DEPOSIT:
        return 'Teller Deposit';
      case TransactionType.BILL_PAYMENT:
        return 'Bill Payment';
      case TransactionType.ACCESS_FEE:
        return 'Access Fee';
      case TransactionType.PURCHASE:
        return 'Purchase';
      case TransactionType.REFUND:
        return 'Refund';
      case TransactionType.INTEREST_EARNED:
        return 'Interest Earned';
      case TransactionType.LOAN_PAYMENT:
        return 'Loan Payment';
      case TransactionType.SALARY:
        return 'Salary';
      case TransactionType.GROCERY:
        return 'Grocery';
      case TransactionType.CARD_PAYMENT:
        return 'Card Payment';
    }
  }
}

extension TransactionDirectionExtension on TransactionDirection {
  String get displayName {
    switch (this) {
      case TransactionDirection.DEBIT:
        return 'Debit';
      case TransactionDirection.CREDIT:
        return 'Credit';
    }
  }

  bool get isDebit => this == TransactionDirection.DEBIT;
  bool get isCredit => this == TransactionDirection.CREDIT;
}