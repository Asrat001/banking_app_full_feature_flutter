class ApiConstants {
  static const String baseUrl = 'https://challenge-api.qena.dev';

  // Auth endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String refreshTokenEndpoint = '/api/auth/refresh-token';

  // Account endpoints
  static const String accountsEndpoint = '/api/accounts';
  static const String createAccountEndpoint = '/api/accounts';
  static const String transferEndpoint = '/api/accounts/transfer';
  static const String billPaymentEndpoint = '/api/accounts/pay-bill';
  static const String accountByIdEndpoint = '/api/accounts'; // append /{id}
  static const String transferDetailsEndpoint =
      '/api/accounts/transfer'; // append /{transactionId}
  static const String billPaymentDetailsEndpoint =
      '/api/accounts/pay-bill'; // append /{transactionId}

  // Transaction endpoints
  static const String transactionsEndpoint =
      '/api/transactions'; // append /{accountId}

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> headersWithAuth(String token) {
    return {
      ...headers,
      'Authorization': 'Bearer $token',
    };
  }
}
