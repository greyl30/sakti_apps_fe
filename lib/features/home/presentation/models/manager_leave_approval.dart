import 'package:flutter/foundation.dart';

enum ManagerApprovalType { permission, sickLeave, emergencyLeave }

class ManagerLeaveApproval {
  const ManagerLeaveApproval({
    required this.id,
    required this.employeeName,
    required this.division,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.remainingLeave,
    required this.reason,
  });

  final String id;
  final String employeeName;
  final String division;
  final ManagerApprovalType type;
  final DateTime startDate;
  final DateTime endDate;
  final int remainingLeave;
  final String reason;

  int get totalDays => endDate.difference(startDate).inDays + 1;
}

// TODO(Backend):
// Ambil daftar pengajuan yang menunggu persetujuan atasan dari API.
final fallbackManagerApproval = ManagerLeaveApproval(
  id: 'manager-approval-fallback',
  employeeName: 'Martin Hasibuan',
  division: 'Divisi Network Administrator',
  type: ManagerApprovalType.permission,
  startDate: DateTime(2026, 7, 28),
  endDate: DateTime(2026, 7, 30),
  remainingLeave: 9,
  reason: 'Izin',
);

final managerApprovalStore = ValueNotifier<List<ManagerLeaveApproval>>([
  ManagerLeaveApproval(
    id: 'manager-approval-001',
    employeeName: 'Martin Hasibuan',
    division: 'Divisi Network Administrator',
    type: ManagerApprovalType.permission,
    startDate: DateTime(2026, 7, 28),
    endDate: DateTime(2026, 7, 30),
    remainingLeave: 9,
    reason: 'Izin',
  ),
  ManagerLeaveApproval(
    id: 'manager-approval-002',
    employeeName: 'Siti Nur Amelia',
    division: 'Divisi Finance',
    type: ManagerApprovalType.sickLeave,
    startDate: DateTime(2026, 7, 23),
    endDate: DateTime(2026, 7, 24),
    remainingLeave: 8,
    reason: 'Cuti sakit',
  ),
  ManagerLeaveApproval(
    id: 'manager-approval-003',
    employeeName: 'Hosea Jeremy Gideon',
    division: 'Divisi IT Support',
    type: ManagerApprovalType.permission,
    startDate: DateTime(2026, 7, 22),
    endDate: DateTime(2026, 7, 23),
    remainingLeave: 7,
    reason: 'Izin',
  ),
  ManagerLeaveApproval(
    id: 'manager-approval-004',
    employeeName: 'Julian Ramadhan',
    division: 'Divisi Operating System',
    type: ManagerApprovalType.emergencyLeave,
    startDate: DateTime(2026, 7, 20),
    endDate: DateTime(2026, 7, 22),
    remainingLeave: 6,
    reason: 'Keperluan keluarga mendadak',
  ),
  ManagerLeaveApproval(
    id: 'manager-approval-005',
    employeeName: 'Jasmina Melati',
    division: 'Divisi Marketing',
    type: ManagerApprovalType.sickLeave,
    startDate: DateTime(2026, 7, 15),
    endDate: DateTime(2026, 7, 17),
    remainingLeave: 9,
    reason: 'Cuti sakit',
  ),
]);

void removeManagerApproval(String id) {
  managerApprovalStore.value = [
    for (final approval in managerApprovalStore.value)
      if (approval.id != id) approval,
  ];
}

String managerApprovalTypeLabel(ManagerApprovalType type) {
  return switch (type) {
    ManagerApprovalType.permission => 'Izin',
    ManagerApprovalType.sickLeave => 'Cuti Sakit',
    ManagerApprovalType.emergencyLeave => 'Cuti Darurat',
  };
}
