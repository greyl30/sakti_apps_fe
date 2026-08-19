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
      clockInTime: _readRequiredTime(json['jam_masuk'], 'jam_masuk'),
      minimumClockInTime: _readRequiredTime(
        json['jam_minimal_masuk'],
        'jam_minimal_masuk',
      ),
      clockOutTime: _readRequiredTime(json['jam_pulang'], 'jam_pulang'),
      minimumClockOutTime: _readRequiredTime(
        json['jam_minimal_pulang'],
        'jam_minimal_pulang',
      ),
      officeRadius: json['radius_kantor'] is int
          ? json['radius_kantor'] as int
          : int.tryParse('${json['radius_kantor']}') ?? 500,
    );
  }

  String get workScheduleLabel {
    return '${_formatTime(minimumClockInTime)} - ${_formatTime(clockOutTime)}';
  }

  String get onTimeDeadlineLabel => _formatTime(clockInTime);

  String get minimumClockInLabel => _formatTime(minimumClockInTime);

  String get minimumClockOutLabel => _formatTime(minimumClockOutTime);

  String get overtimeDeadlineLabel => _formatTime(clockOutTime);

  DateTime clockInDateTime(DateTime referenceDate) {
    return _timeOfDayDateTime(clockInTime, referenceDate);
  }

  DateTime minimumClockInDateTime(DateTime referenceDate) {
    return _timeOfDayDateTime(minimumClockInTime, referenceDate);
  }

  DateTime clockOutDateTime(DateTime referenceDate) {
    return _timeOfDayDateTime(clockOutTime, referenceDate);
  }

  DateTime minimumClockOutDateTime(DateTime referenceDate) {
    return _timeOfDayDateTime(minimumClockOutTime, referenceDate);
  }

  DateTime _timeOfDayDateTime(String value, DateTime referenceDate) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.elementAtOrNull(0) ?? '') ?? 0;
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

String _readRequiredTime(Object? value, String fieldName) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    throw FormatException('$fieldName tidak tersedia.');
  }

  final parts = text.split(':');
  final hour = int.tryParse(parts.elementAtOrNull(0) ?? '');
  final minute = int.tryParse(parts.elementAtOrNull(1) ?? '');
  final second = int.tryParse(parts.elementAtOrNull(2) ?? '') ?? 0;
  if (hour == null ||
      minute == null ||
      hour < 0 ||
      hour > 23 ||
      minute < 0 ||
      minute > 59 ||
      second < 0 ||
      second > 59) {
    throw FormatException('$fieldName tidak valid.');
  }

  return text;
}

String _formatTime(String value) {
  final parts = value.split(':');
  final hour = int.tryParse(parts.elementAtOrNull(0) ?? '') ?? 0;
  final minute = int.tryParse(parts.elementAtOrNull(1) ?? '') ?? 0;
  return '${hour.toString().padLeft(2, '0')}.${minute.toString().padLeft(2, '0')}';
}
