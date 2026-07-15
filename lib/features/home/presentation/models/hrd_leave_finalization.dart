import 'package:flutter/foundation.dart';

import 'manager_leave_approval.dart';

class HrdLeaveFinalization {
  const HrdLeaveFinalization({
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

  ManagerLeaveApproval toApprovalView() {
    return ManagerLeaveApproval(
      id: id,
      employeeName: employeeName,
      division: division,
      type: type,
      startDate: startDate,
      endDate: endDate,
      remainingLeave: remainingLeave,
      reason: reason,
    );
  }
}

// TODO(Backend):
// Ambil daftar cuti yang sudah disetujui atasan dan menunggu finalisasi HRD.
final fallbackHrdFinalization = HrdLeaveFinalization(
  id: 'hrd-finalization-fallback',
  employeeName: 'Martin Hasibuan',
  division: 'Divisi Network Administrator',
  type: ManagerApprovalType.permission,
  startDate: DateTime(2026, 7, 28),
  endDate: DateTime(2026, 7, 30),
  remainingLeave: 6,
  reason: 'Izin',
);

final hrdFinalizationStore = ValueNotifier<List<HrdLeaveFinalization>>([
  HrdLeaveFinalization(
    id: 'hrd-finalization-001',
    employeeName: 'Martin Hasibuan',
    division: 'Divisi Network Administrator',
    type: ManagerApprovalType.permission,
    startDate: DateTime(2026, 7, 28),
    endDate: DateTime(2026, 7, 30),
    remainingLeave: 6,
    reason: 'Izin',
  ),
  HrdLeaveFinalization(
    id: 'hrd-finalization-002',
    employeeName: 'Siti Nur Amelia',
    division: 'Divisi Finance',
    type: ManagerApprovalType.sickLeave,
    startDate: DateTime(2026, 7, 23),
    endDate: DateTime(2026, 7, 24),
    remainingLeave: 8,
    reason: 'Cuti sakit',
  ),
  HrdLeaveFinalization(
    id: 'hrd-finalization-003',
    employeeName: 'Hosea Jeremy Gideon',
    division: 'Divisi IT Support',
    type: ManagerApprovalType.permission,
    startDate: DateTime(2026, 7, 22),
    endDate: DateTime(2026, 7, 23),
    remainingLeave: 7,
    reason: 'Izin',
  ),
  HrdLeaveFinalization(
    id: 'hrd-finalization-004',
    employeeName: 'Julian Ramadhan',
    division: 'Divisi Operating System',
    type: ManagerApprovalType.emergencyLeave,
    startDate: DateTime(2026, 7, 20),
    endDate: DateTime(2026, 7, 22),
    remainingLeave: 6,
    reason: 'Keperluan keluarga mendadak',
  ),
  HrdLeaveFinalization(
    id: 'hrd-finalization-005',
    employeeName: 'Jasmina Melati',
    division: 'Divisi Marketing',
    type: ManagerApprovalType.sickLeave,
    startDate: DateTime(2026, 7, 15),
    endDate: DateTime(2026, 7, 17),
    remainingLeave: 9,
    reason: 'Cuti sakit',
  ),
]);

void removeHrdFinalization(String id) {
  hrdFinalizationStore.value = [
    for (final finalization in hrdFinalizationStore.value)
      if (finalization.id != id) finalization,
  ];
}
