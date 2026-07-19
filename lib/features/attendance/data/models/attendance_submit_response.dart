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

  bool get isOutsideRadius => data['is_outside_radius'] == true;

  num? get distanceMeter {
    final value = data['distance_meter'];
    return value is num ? value : num.tryParse(value?.toString() ?? '');
  }

  String? get locationStatus {
    final value = data['location_status'];
    if (value is! String || value.trim().isEmpty) return null;
    return value;
  }

  num? get officeRadius {
    final value = data['office_radius'];
    return value is num ? value : num.tryParse(value?.toString() ?? '');
  }
}
