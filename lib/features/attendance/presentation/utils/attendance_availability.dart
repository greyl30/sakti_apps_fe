import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/attendance_remote_data_source.dart';
import '../../data/models/attendance_work_config.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../../history/presentation/models/attendance_history_model.dart';
import '../../../leave/data/models/leave_request_model.dart';
import '../../../leave/presentation/utils/leave_workday_calculator.dart';

final attendanceWorkConfigRepositoryProvider = Provider<AttendanceRepository>((
  ref,
) {
  return AttendanceRepository(AttendanceRemoteDataSource(ApiClient.dio));
});

final attendanceWorkConfigProvider = FutureProvider<AttendanceWorkConfig>((
  ref,
) async {
  final repository = ref.watch(attendanceWorkConfigRepositoryProvider);
  return repository.getWorkConfig();
});

class AttendanceAvailability {
  const AttendanceAvailability({
    required this.isCalendarHoliday,
    required this.isAttendanceUnavailable,
    required this.hasClockIn,
    required this.hasClockOut,
    required this.canCheckIn,
    required this.canCheckOut,
    this.checkInUnavailableReason,
    this.checkOutUnavailableReason,
  });

  final bool isCalendarHoliday;
  final bool isAttendanceUnavailable;
  final bool hasClockIn;
  final bool hasClockOut;
  final bool canCheckIn;
  final bool canCheckOut;
  final AttendanceUnavailableReason? checkInUnavailableReason;
  final AttendanceUnavailableReason? checkOutUnavailableReason;
}

class AttendanceUnavailableReason {
  const AttendanceUnavailableReason({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;
}

AttendanceAvailability buildAttendanceAvailability({
  required DateTime date,
  required Set<DateTime> holidays,
  required List<LeaveRequestResponse> leaveRequests,
  required List<AttendanceHistoryModel>? histories,
  AttendanceWorkConfig? workConfig,
}) {
  final targetDate = normalizeLeaveDate(date);
  final hasClockIn = hasClockInToday(histories, targetDate);
  final hasClockOut = hasClockOutToday(histories, targetDate);
  final unavailableReason = _attendanceUnavailableReason(
    targetDate,
    holidays,
    leaveRequests,
  );
  final checkInReason =
      unavailableReason ??
      (hasClockIn
          ? const AttendanceUnavailableReason(
              title: 'Presensi Masuk Sudah Dilakukan',
              message: 'Anda sudah melakukan presensi masuk',
            )
          : _isBeforeMinimumClockIn(date, workConfig)
          ? AttendanceUnavailableReason(
              title: 'Presensi Masuk Belum Tersedia',
              message:
                  'Presensi masuk hanya dapat dilakukan mulai pukul '
                  '${workConfig!.minimumClockInLabel}',
            )
          : null);
  final checkOutReason =
      unavailableReason ??
      (!hasClockIn
          ? const AttendanceUnavailableReason(
              title: 'Presensi Keluar Belum Tersedia',
              message: 'Anda belum melakukan presensi masuk',
            )
          : hasClockOut
          ? const AttendanceUnavailableReason(
              title: 'Presensi Tidak Tersedia',
              message: 'Anda sudah melakukan presensi keluar',
            )
          : _isBeforeMinimumClockOut(date, workConfig)
          ? AttendanceUnavailableReason(
              title: 'Presensi Keluar Belum Tersedia',
              message:
                  'Presensi keluar hanya dapat dilakukan mulai pukul '
                  '${workConfig!.minimumClockOutLabel}',
            )
          : null);

  return AttendanceAvailability(
    isCalendarHoliday: _isCalendarHoliday(targetDate, holidays),
    isAttendanceUnavailable: unavailableReason != null,
    hasClockIn: hasClockIn,
    hasClockOut: hasClockOut,
    canCheckIn: checkInReason == null,
    canCheckOut: checkOutReason == null,
    checkInUnavailableReason: checkInReason,
    checkOutUnavailableReason: checkOutReason,
  );
}

bool _isBeforeMinimumClockIn(DateTime date, AttendanceWorkConfig? workConfig) {
  return workConfig != null &&
      date.isBefore(workConfig.minimumClockInDateTime(date));
}

bool _isBeforeMinimumClockOut(DateTime date, AttendanceWorkConfig? workConfig) {
  return workConfig != null &&
      date.isBefore(workConfig.minimumClockOutDateTime(date));
}

bool hasClockInToday(
  List<AttendanceHistoryModel>? histories,
  DateTime targetDate,
) {
  return histories
          ?.where((history) => _isSameDate(history.date, targetDate))
          .any((history) => history.clockInTime != null) ??
      false;
}

bool hasClockOutToday(
  List<AttendanceHistoryModel>? histories,
  DateTime targetDate,
) {
  return histories
          ?.where((history) => _isSameDate(history.date, targetDate))
          .any((history) => history.clockOutTime != null) ??
      false;
}

AttendanceUnavailableReason? _attendanceUnavailableReason(
  DateTime targetDate,
  Set<DateTime> holidays,
  List<LeaveRequestResponse> leaveRequests,
) {
  if (_isCalendarHoliday(targetDate, holidays)) {
    return const AttendanceUnavailableReason(
      title: 'Hari Ini Adalah Hari Libur',
      message: 'Hari ini hari libur',
    );
  }

  for (final request in leaveRequests) {
    if (!request.blocksAttendanceReminder || !request.coversDate(targetDate)) {
      continue;
    }

    if (request.isDispensation) {
      return const AttendanceUnavailableReason(
        title: 'Presensi Tidak Tersedia',
        message: 'Hari ini Anda sedang dispensasi',
      );
    }

    return const AttendanceUnavailableReason(
      title: 'Presensi Tidak Tersedia',
      message: 'Hari ini Anda sedang cuti',
    );
  }

  return null;
}

bool _isCalendarHoliday(DateTime date, Set<DateTime> holidays) {
  final normalizedDate = normalizeLeaveDate(date);
  return normalizedDate.weekday == DateTime.saturday ||
      normalizedDate.weekday == DateTime.sunday ||
      holidays.contains(normalizedDate);
}

bool _isSameDate(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
