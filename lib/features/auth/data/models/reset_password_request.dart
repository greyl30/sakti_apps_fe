class ResetPasswordRequest {
  const ResetPasswordRequest({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String token;
  final String newPassword;
  final String confirmPassword;

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    };
  }
}
