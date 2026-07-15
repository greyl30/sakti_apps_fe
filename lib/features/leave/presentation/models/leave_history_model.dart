enum LeaveHistoryStatus { approved, rejected }

class LeaveHistoryModel {
  const LeaveHistoryModel({
    required this.id,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  final String id;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final LeaveHistoryStatus status;
}

// Dummy data dibuat seperti response backend agar source data mudah diganti.
final dummyLeaveHistories = [
  LeaveHistoryModel(
    id: 'leave-history-001',
    leaveType: 'Izin',
    startDate: DateTime(2026, 5, 22),
    endDate: DateTime(2026, 5, 22),
    status: LeaveHistoryStatus.approved,
  ),
  LeaveHistoryModel(
    id: 'leave-history-002',
    leaveType: 'Izin',
    startDate: DateTime(2026, 3, 16),
    endDate: DateTime(2026, 3, 19),
    status: LeaveHistoryStatus.approved,
  ),
  LeaveHistoryModel(
    id: 'leave-history-003',
    leaveType: 'Izin',
    startDate: DateTime(2026, 1, 3),
    endDate: DateTime(2026, 1, 3),
    status: LeaveHistoryStatus.rejected,
  ),
  LeaveHistoryModel(
    id: 'leave-history-004',
    leaveType: 'Cuti Sakit',
    startDate: DateTime(2025, 12, 20),
    endDate: DateTime(2025, 12, 23),
    status: LeaveHistoryStatus.approved,
  ),
  LeaveHistoryModel(
    id: 'leave-history-005',
    leaveType: 'Cuti Darurat',
    startDate: DateTime(2025, 12, 8),
    endDate: DateTime(2025, 12, 11),
    status: LeaveHistoryStatus.approved,
  ),
  LeaveHistoryModel(
    id: 'leave-history-006',
    leaveType: 'Izin',
    startDate: DateTime(2025, 12, 2),
    endDate: DateTime(2025, 12, 2),
    status: LeaveHistoryStatus.rejected,
  ),
];
