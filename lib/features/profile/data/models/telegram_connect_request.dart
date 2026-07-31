class TelegramConnectRequest {
  const TelegramConnectRequest({required this.verificationCode});

  final String verificationCode;

  Map<String, dynamic> toJson() {
    return {'verification_code': verificationCode};
  }
}
