class LeaveFormData {
  const LeaveFormData({
    required this.type,
    required this.reason,
    required this.startDate,
    required this.endDate,
  });

  final String type;
  final String reason;
  final DateTime startDate;
  final DateTime endDate;

  int get totalDays => endDate.difference(startDate).inDays + 1;
}
