enum EmergencyHistoryType { dispensation, emergencyLeave }

enum EmergencyHistoryStatus { approved, rejected }

class EmergencyHistoryModel {
  const EmergencyHistoryModel({
    required this.id,
    required this.requestType,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  final String id;
  final EmergencyHistoryType requestType;
  final DateTime startDate;
  final DateTime endDate;
  final EmergencyHistoryStatus status;
}

// Dummy data dibuat seperti response backend agar source data mudah diganti.
final dummyEmergencyHistories = [
  EmergencyHistoryModel(
    id: 'emergency-history-001',
    requestType: EmergencyHistoryType.dispensation,
    startDate: DateTime(2026, 3, 25),
    endDate: DateTime(2026, 3, 25),
    status: EmergencyHistoryStatus.approved,
  ),
  EmergencyHistoryModel(
    id: 'emergency-history-002',
    requestType: EmergencyHistoryType.emergencyLeave,
    startDate: DateTime(2026, 2, 16),
    endDate: DateTime(2026, 2, 19),
    status: EmergencyHistoryStatus.approved,
  ),
  EmergencyHistoryModel(
    id: 'emergency-history-003',
    requestType: EmergencyHistoryType.dispensation,
    startDate: DateTime(2026, 2, 14),
    endDate: DateTime(2026, 2, 14),
    status: EmergencyHistoryStatus.approved,
  ),
  EmergencyHistoryModel(
    id: 'emergency-history-004',
    requestType: EmergencyHistoryType.emergencyLeave,
    startDate: DateTime(2025, 1, 20),
    endDate: DateTime(2025, 1, 23),
    status: EmergencyHistoryStatus.rejected,
  ),
];
