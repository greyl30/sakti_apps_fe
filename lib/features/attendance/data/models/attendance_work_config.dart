class AttendanceWorkConfig {
  const AttendanceWorkConfig({
    required this.clockInTime,
    required this.minimumClockInTime,
    required this.clockOutTime,
    required this.minimumClockOutTime,
    required this.officeRadius,
  });

  final String clockInTime;
  final String minimumClockInTime;
  final String clockOutTime;
  final String minimumClockOutTime;
  final int officeRadius;

  factory AttendanceWorkConfig.fromJson(Map<String, dynamic> json) {
    return AttendanceWorkConfig(
      clockInTime: json['jam_masuk'] as String? ?? '08:30:00',
      minimumClockInTime: json['jam_minimal_masuk'] as String? ?? '08:00:00',
      clockOutTime: json['jam_pulang'] as String? ?? '17:00:00',
      minimumClockOutTime: json['jam_minimal_pulang'] as String? ?? '16:00:00',
      officeRadius: json['radius_kantor'] is int
          ? json['radius_kantor'] as int
          : int.tryParse('${json['radius_kantor']}') ?? 500,
    );
  }

  DateTime clockOutDateTime(DateTime referenceDate) {
    final parts = clockOutTime.split(':');
    final hour = int.tryParse(parts.elementAtOrNull(0) ?? '') ?? 17;
    final minute = int.tryParse(parts.elementAtOrNull(1) ?? '') ?? 0;
    final second = int.tryParse(parts.elementAtOrNull(2) ?? '') ?? 0;

    return DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
      hour,
      minute,
      second,
    );
  }
}
