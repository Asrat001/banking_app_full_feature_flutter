class ValidationUtils {
  /// Validate Ethiopian phone numbers
  static String? validateEthiopianPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter phone number';
    }
    const pattern = r'^(?:\+2519\d{8}|09\d{8})$';
    final regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Enter a valid Ethiopian phone number';
    }
    return null;
  }

  /// Validate strong password
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    final regex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#ETB%^&*(),.?":{}|<>]).{8,}$',
    );
    if (!regex.hasMatch(value)) {
      return 'Must contain uppercase, lowercase, number & special char';
    }
    return null;
  }

  /// Simple username validation
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter username';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 8) {
      return 'Username must be no more than 50 characters';
    }
    return null;
  }

  /// Simple name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter username';
    }
    if (value.length < 5) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 20) {
      return 'Username must be no more than 50 characters';
    }
    return null;
  }

}
