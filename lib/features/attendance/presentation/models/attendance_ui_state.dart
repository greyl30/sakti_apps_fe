class AttendanceUiState {
  const AttendanceUiState({
    required this.isHoliday,
    required this.hasClockIn,
    required this.hasClockOut,
  });

  // Dummy state sementara sampai backend hari libur/presensi tersedia.
  final bool isHoliday;
  final bool hasClockIn;
  final bool hasClockOut;
}

const dummyAttendanceUiState = AttendanceUiState(
  isHoliday: false,
  hasClockIn: true,
  hasClockOut: false,
);
