class FcmTokenRegistrationRequest {
  const FcmTokenRegistrationRequest({required this.fcmToken});

  final String fcmToken;

  Map<String, dynamic> toJson() {
    return {'fcm_token': fcmToken};
  }
}
