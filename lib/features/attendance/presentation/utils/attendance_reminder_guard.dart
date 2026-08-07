import '../../../leave/data/models/leave_request_model.dart';
import '../../../leave/presentation/utils/leave_workday_calculator.dart';

bool isAttendanceReminderSuppressed({
  required DateTime date,
  required Set<DateTime> holidays,
  required List<LeaveRequestResponse> leaveRequests,
}) {
  final targetDate = normalizeLeaveDate(date);

  return _isWeekend(targetDate) ||
      holidays.contains(targetDate) ||
      leaveRequests.any(
        (request) =>
            request.blocksAttendanceReminder && request.coversDate(targetDate),
      );
}

bool _isWeekend(DateTime date) {
  return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
}
