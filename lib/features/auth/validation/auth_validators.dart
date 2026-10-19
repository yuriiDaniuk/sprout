abstract final class AuthValidators {
  static String? name(String? value) =>
      value == null || value.trim().isEmpty ? 'Enter your name.' : null;
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter your email.';
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())
        ? null
        : 'Enter a valid email address.';
  }

  static String? requiredPassword(String? value) =>
      value == null || value.isEmpty ? 'Enter your password.' : null;
  static String? newPassword(String? value) {
    if (value == null || value.length < 8) return 'Use at least 8 characters.';
    return RegExp(r'[A-Z]').hasMatch(value)
        ? null
        : 'Include at least one uppercase letter (A–Z).';
  }
}
