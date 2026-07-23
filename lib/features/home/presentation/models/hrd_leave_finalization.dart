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
    this.totalDaysOverride,
  });

  final String id;
  final String employeeName;
  final String division;
  final ManagerApprovalType type;
  final DateTime startDate;
  final DateTime endDate;
  final int? remainingLeave;
  final String reason;
  final int? totalDaysOverride;

  int get totalDays =>
      totalDaysOverride ?? endDate.difference(startDate).inDays + 1;

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
      totalDaysOverride: totalDaysOverride,
    );
  }
}
