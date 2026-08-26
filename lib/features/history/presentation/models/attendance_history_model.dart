enum AttendanceHistoryStatus { onTime, late, overtime }

class AttendanceHistoryModel {
  const AttendanceHistoryModel({
    required this.id,
    required this.employeeId,
    required this.status,
    required this.date,
    this.clockInTime,
    this.clockOutTime,
    this.isOvertime = false,
  });

  final String id;
  final String employeeId;
  final AttendanceHistoryStatus status;
  final DateTime date;
  final String? clockInTime;
  final String? clockOutTime;
  final bool isOvertime;

  factory AttendanceHistoryModel.fromJson(Map<dynamic, dynamic> json) {
    final status = _parseStatus(json['status'], json['lembur']);
    final date =
        DateTime.tryParse('${json['tanggal'] ?? ''}') ??
        DateTime.fromMillisecondsSinceEpoch(0);

    return AttendanceHistoryModel(
      id: '${json['id'] ?? date.toIso8601String()}',
      employeeId: _readEmployeeId(json),
      status: status,
      date: date,
      clockInTime: _readTime(json['jam_masuk']),
      clockOutTime: _readTime(json['jam_keluar']),
      isOvertime: json['lembur'] == true,
    );
  }

  String get clockInLabel => _formatTime(clockInTime);

  String get clockOutLabel => _formatTime(clockOutTime);

  static AttendanceHistoryStatus _parseStatus(
    dynamic status,
    dynamic overtime,
  ) {
    if (overtime == true) return AttendanceHistoryStatus.overtime;

    final value = status?.toString().toLowerCase();
    if (value == 'terlambat' || value == 'late') {
      return AttendanceHistoryStatus.late;
    }

    return AttendanceHistoryStatus.onTime;
  }

  static String? _readTime(dynamic value) {
    final text = value?.toString().trim();
    final normalized = text?.toLowerCase();
    if (text == null ||
        text.isEmpty ||
        normalized == 'null' ||
        normalized == '-' ||
        normalized == '--:--' ||
        normalized == '00:00' ||
        normalized == '00:00:00') {
      return null;
    }

    return text;
  }

  static String _readEmployeeId(Map<dynamic, dynamic> json) {
    for (final key in const [
      'karyawan_id',
      'employee_id',
      'user_id',
      'karyawanId',
      'employeeId',
      'userId',
    ]) {
      final value = json[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }

    final employee = json['karyawan'];
    if (employee is Map) {
      for (final key in const ['id', 'karyawan_id', 'user_id']) {
        final value = employee[key]?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }
    }

    final user = json['user'];
    if (user is Map) {
      for (final key in const ['id', 'karyawan_id', 'user_id']) {
        final value = user[key]?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }
    }

    return '';
  }

  static String _formatTime(String? value) {
    if (value == null) return '-';

    final timeText = _extractWibTimeText(value);
    final parts = timeText.split(':');
    final hour = int.tryParse(parts.elementAtOrNull(0) ?? '');
    final minute = int.tryParse(parts.elementAtOrNull(1) ?? '');
    if (hour == null || minute == null) return value;

    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }

  static String _extractWibTimeText(String value) {
    final timePart = value.contains('T') ? value.split('T').last : value;
    return timePart.split(RegExp(r'[Z+-]')).first;
  }
}
