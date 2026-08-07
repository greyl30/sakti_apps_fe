class LeaveHolidayModel {
  const LeaveHolidayModel({required this.date, required this.isActive});

  final DateTime date;
  final bool isActive;

  factory LeaveHolidayModel.fromJson(Map<String, dynamic> json) {
    return LeaveHolidayModel(
      date: _readDate(
        json['tanggal'] ??
            json['tanggal_libur'] ??
            json['date'] ??
            json['holiday_date'],
      ),
      isActive: _readBool(
        json['aktif'] ?? json['is_active'] ?? json['active'] ?? json['status'],
      ),
    );
  }
}

DateTime _readDate(Object? value) {
  final parsed = DateTime.tryParse(value?.toString().trim() ?? '');
  if (parsed == null) return DateTime.fromMillisecondsSinceEpoch(0);
  return DateTime(parsed.year, parsed.month, parsed.day);
}

bool _readBool(Object? value) {
  if (value == null) return true;
  if (value is bool) return value;
  if (value is num) return value != 0;

  final normalized = value.toString().trim().toLowerCase();
  if (normalized.isEmpty) return true;
  return normalized == 'true' ||
      normalized == '1' ||
      normalized == 'aktif' ||
      normalized == 'active';
}
