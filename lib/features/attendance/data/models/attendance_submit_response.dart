class AttendanceSubmitResponse {
  const AttendanceSubmitResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final Map<String, dynamic> data;

  factory AttendanceSubmitResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return AttendanceSubmitResponse(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: rawData is Map<String, dynamic>
          ? rawData
          : Map<String, dynamic>.from(rawData as Map? ?? {}),
    );
  }

  bool get isOvertime => data['lembur'] == true;
}
