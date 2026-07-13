class EmergencyDispensationData {
  const EmergencyDispensationData({
    required this.reason,
    required this.startDate,
    required this.endDate,
  });

  final String reason;
  final DateTime startDate;
  final DateTime endDate;
}

const dummyEmergencyReason = 'Mengantar anak ke rumah sakit';

EmergencyDispensationData dummyEmergencyDispensationData() {
  return EmergencyDispensationData(
    reason: dummyEmergencyReason,
    startDate: DateTime(2026, 7, 6),
    endDate: DateTime(2026, 7, 7),
  );
}
