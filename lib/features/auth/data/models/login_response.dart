import 'package:json_annotation/json_annotation.dart';

import 'user_model.dart';

part 'login_response.g.dart';

// Response login dari backend
@JsonSerializable()
class LoginResponse {
  const LoginResponse({this.data, required this.success, this.message});

  final LoginData? data;
  final bool success;
  final String? message;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class LoginData {
  const LoginData({required this.accessToken, required this.user});

  @JsonKey(name: 'access_token')
  final String accessToken;

  final UserModel user;

  factory LoginData.fromJson(Map<String, dynamic> json) =>
      _$LoginDataFromJson(json);

  Map<String, dynamic> toJson() => _$LoginDataToJson(this);
}
