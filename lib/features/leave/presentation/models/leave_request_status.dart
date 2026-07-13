enum LeaveApprovalStage { currentSupervisor, currentHRD }

enum LeaveApprovalStatus { waitingSupervisor, waitingHRD, approved }

enum ApprovalProgress { submitted, waitingSupervisor, waitingHRD, approved }

class LeaveRequestStatusData {
  const LeaveRequestStatusData({
    required this.type,
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.submittedDate,
    required this.supervisorName,
    required this.hrdName,
    required this.stage,
    required this.status,
    required this.progress,
    this.supervisorApprovalDate,
    this.hrdApprovalDate,
  });

  final String type;
  final String reason;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime submittedDate;
  final String supervisorName;
  final String hrdName;
  final LeaveApprovalStage stage;
  // Development dummy status. Nantinya seluruh status berasal dari backend.
  final LeaveApprovalStatus status;
  final ApprovalProgress progress;
  final DateTime? supervisorApprovalDate;
  final DateTime? hrdApprovalDate;

  int get totalDays => endDate.difference(startDate).inDays + 1;
}

class LeaveStatusRouteData {
  const LeaveStatusRouteData({
    required this.data,
    this.fallbackRoute = '/leave',
    this.bottomNavigationIndex = 2,
  });

  final LeaveRequestStatusData data;
  final String fallbackRoute;
  final int bottomNavigationIndex;
}

final dummyLeaveWaitingSupervisor = LeaveRequestStatusData(
  type: 'Izin',
  reason: 'Izin',
  startDate: DateTime(2026, 7, 13),
  endDate: DateTime(2026, 7, 15),
  submittedDate: DateTime(2025, 7, 10),
  supervisorName: 'Hendru Kusuma',
  hrdName: 'HRD',
  stage: LeaveApprovalStage.currentSupervisor,
  status: LeaveApprovalStatus.waitingSupervisor,
  progress: ApprovalProgress.waitingSupervisor,
);

final dummyLeaveWaitingHRD = LeaveRequestStatusData(
  type: 'Izin',
  reason: 'Izin',
  startDate: DateTime(2026, 7, 13),
  endDate: DateTime(2026, 7, 15),
  submittedDate: DateTime(2026, 7, 10, 9, 15),
  supervisorName: 'Hendru Kusuma',
  hrdName: 'HRD',
  stage: LeaveApprovalStage.currentHRD,
  status: LeaveApprovalStatus.waitingHRD,
  progress: ApprovalProgress.waitingHRD,
  supervisorApprovalDate: DateTime(2026, 7, 10, 11, 35),
);

final dummyLeaveApproved = LeaveRequestStatusData(
  type: 'Izin',
  reason: 'Izin',
  startDate: DateTime(2026, 7, 13),
  endDate: DateTime(2026, 7, 15),
  submittedDate: DateTime(2026, 7, 10, 9, 15),
  supervisorName: 'Hendru Kusuma',
  hrdName: 'HRD',
  stage: LeaveApprovalStage.currentHRD,
  status: LeaveApprovalStatus.approved,
  progress: ApprovalProgress.approved,
  supervisorApprovalDate: DateTime(2026, 7, 10, 11, 35),
  hrdApprovalDate: DateTime(2026, 7, 10, 14, 20),
);

final dummyEmergencyLeaveWaitingSupervisor = LeaveRequestStatusData(
  type: 'Cuti Darurat',
  reason: 'Pemulihan kesehatan',
  startDate: DateTime(2026, 7, 2),
  endDate: DateTime(2026, 7, 4),
  submittedDate: DateTime(2026, 7, 6),
  supervisorName: 'Hendru Kusuma',
  hrdName: 'HRD',
  stage: LeaveApprovalStage.currentSupervisor,
  status: LeaveApprovalStatus.waitingSupervisor,
  progress: ApprovalProgress.waitingSupervisor,
);
