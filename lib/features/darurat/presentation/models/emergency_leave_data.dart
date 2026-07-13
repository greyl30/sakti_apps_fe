import '../../../leave/presentation/models/leave_request_status.dart';

class EmergencyLeaveData {
  const EmergencyLeaveData({
    required this.reason,
    required this.startDate,
    required this.endDate,
  });

  final String reason;
  final DateTime startDate;
  final DateTime endDate;

  int get totalDays => endDate.difference(startDate).inDays + 1;

  LeaveRequestStatusData toStatusData() {
    // Data dummy development, nantinya diganti dari response backend.
    return LeaveRequestStatusData(
      type: 'Cuti Darurat',
      reason: reason,
      startDate: startDate,
      endDate: endDate,
      submittedDate: DateTime(2026, 7, 6),
      supervisorName: 'Hendru Kusuma',
      hrdName: 'HRD',
      stage: LeaveApprovalStage.currentSupervisor,
      status: LeaveApprovalStatus.waitingSupervisor,
      progress: ApprovalProgress.waitingSupervisor,
    );
  }
}

EmergencyLeaveData dummyEmergencyLeaveData() {
  return EmergencyLeaveData(
    reason: 'Pemulihan kesehatan',
    startDate: DateTime(2026, 7, 2),
    endDate: DateTime(2026, 7, 4),
  );
}
