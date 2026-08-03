class ChangePasswordResponse {
  const ChangePasswordResponse({
    required this.success,
    required this.message,
    required this.forceLogout,
  });

  final bool success;
  final String message;
  final bool forceLogout;

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(
      success: json['success'] == true,
      message:
          json['message']?.toString().trim() ??
          'Password berhasil diubah. Silakan login kembali.',
      forceLogout: json['force_logout'] == true,
    );
  }
}
