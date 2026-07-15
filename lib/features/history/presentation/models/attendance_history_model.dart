enum AttendanceHistoryType { clockIn, clockOut }

enum AttendanceHistoryStatus { onTime, late, overtime }

class AttendanceHistoryModel {
  const AttendanceHistoryModel({
    required this.id,
    required this.attendanceType,
    required this.status,
    required this.date,
    required this.time,
  });

  final String id;
  final AttendanceHistoryType attendanceType;
  final AttendanceHistoryStatus status;
  final DateTime date;
  final String time;
}

// Dummy data dibuat seperti response backend agar source data mudah diganti.
final dummyAttendanceHistories = [
  AttendanceHistoryModel(
    id: 'history-001',
    attendanceType: AttendanceHistoryType.clockOut,
    status: AttendanceHistoryStatus.overtime,
    date: DateTime(2026, 7, 2),
    time: '18:33',
  ),
  AttendanceHistoryModel(
    id: 'history-002',
    attendanceType: AttendanceHistoryType.clockIn,
    status: AttendanceHistoryStatus.onTime,
    date: DateTime(2026, 7, 2),
    time: '08:00',
  ),
  AttendanceHistoryModel(
    id: 'history-003',
    attendanceType: AttendanceHistoryType.clockOut,
    status: AttendanceHistoryStatus.onTime,
    date: DateTime(2026, 7, 1),
    time: '16:10',
  ),
  AttendanceHistoryModel(
    id: 'history-004',
    attendanceType: AttendanceHistoryType.clockIn,
    status: AttendanceHistoryStatus.late,
    date: DateTime(2026, 7, 1),
    time: '09:17',
  ),
  AttendanceHistoryModel(
    id: 'history-005',
    attendanceType: AttendanceHistoryType.clockOut,
    status: AttendanceHistoryStatus.onTime,
    date: DateTime(2026, 6, 30),
    time: '16:00',
  ),
  AttendanceHistoryModel(
    id: 'history-006',
    attendanceType: AttendanceHistoryType.clockIn,
    status: AttendanceHistoryStatus.late,
    date: DateTime(2026, 6, 30),
    time: '09:05',
  ),
];
