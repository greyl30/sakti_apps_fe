enum AttendanceHistoryStatus { onTime, late, overtime }

class AttendanceHistoryModel {
  const AttendanceHistoryModel({
    required this.id,
    required this.status,
    required this.date,
    this.clockInTime,
    this.clockOutTime,
    this.isOvertime = false,
  });

  final String id;
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
    if (text == null || text.isEmpty || text == 'null') return null;
    return text;
  }

  static String _formatTime(String? value) {
    if (value == null) return '-';

    final parsedDateTime = DateTime.tryParse(value);
    if (parsedDateTime != null) {
      final hour = parsedDateTime.hour.toString().padLeft(2, '0');
      final minute = parsedDateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    final parts = value.split(':');
    final hour = int.tryParse(parts.elementAtOrNull(0) ?? '');
    final minute = int.tryParse(parts.elementAtOrNull(1) ?? '');
    if (hour == null || minute == null) return value;

    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }
}
