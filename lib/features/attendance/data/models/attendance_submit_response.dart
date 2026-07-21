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

  String? get attendanceStatus {
    final value = data['status'];
    if (value is! String || value.trim().isEmpty) return null;
    return value;
  }

  bool get isLate => attendanceStatus?.toLowerCase() == 'terlambat';

  String? get attendanceDate {
    final value = data['tanggal'];
    if (value is! String || value.trim().isEmpty) return null;
    return value;
  }

  String? get clockInTime {
    final value = data['jam_masuk'];
    if (value is! String || value.trim().isEmpty) return null;
    return value;
  }

  String? get clockOutTime {
    final value = data['jam_keluar'];
    if (value is! String || value.trim().isEmpty) return null;
    return value;
  }

  bool get isOutsideRadius => data['is_outside_radius'] == true;

  num? get distanceMeter {
    final value = data['distance_meter'];
    return value is num ? value : num.tryParse(value?.toString() ?? '');
  }

  String? get locationStatus {
    final value = clockOutTime == null
        ? data['lokasi_status_masuk']
        : data['lokasi_status_keluar'];
    if (value is! String || value.trim().isEmpty) return null;
    return value;
  }

  num? get officeRadius {
    final value = data['office_radius'];
    return value is num ? value : num.tryParse(value?.toString() ?? '');
  }
}
