// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      data: json['data'] == null
          ? null
          : LoginData.fromJson(json['data'] as Map<String, dynamic>),
      success: json['success'] as bool,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'success': instance.success,
      'message': instance.message,
    };

LoginData _$LoginDataFromJson(Map<String, dynamic> json) => LoginData(
  accessToken: json['access_token'] as String,
  user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LoginDataToJson(LoginData instance) => <String, dynamic>{
  'access_token': instance.accessToken,
  'user': instance.user,
};
