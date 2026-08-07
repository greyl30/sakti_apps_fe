class LeaveFormData {
  const LeaveFormData({
    required this.type,
    required this.reason,
    required this.startDate,
    required this.endDate,
    this.totalWorkdays,
  });

  final String type;
  final String reason;
  final DateTime startDate;
  final DateTime endDate;
  final int? totalWorkdays;

  int get totalDays =>
      totalWorkdays ?? endDate.difference(startDate).inDays + 1;
}
