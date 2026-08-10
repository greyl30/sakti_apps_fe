import '../../../leave/data/models/leave_request_model.dart';
import '../../../leave/presentation/utils/leave_workday_calculator.dart';
import 'attendance_availability.dart';

bool isAttendanceReminderSuppressed({
  required DateTime date,
  required Set<DateTime> holidays,
  required List<LeaveRequestResponse> leaveRequests,
}) {
  final targetDate = normalizeLeaveDate(date);

  return buildAttendanceAvailability(
    date: targetDate,
    holidays: holidays,
    leaveRequests: leaveRequests,
    histories: null,
  ).isAttendanceUnavailable;
}
