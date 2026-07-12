class AttendanceUiState {
  const AttendanceUiState({required this.isHoliday, required this.hasClockIn});

  // Dummy state sementara sampai backend hari libur/presensi tersedia.
  final bool isHoliday;
  final bool hasClockIn;
}

const dummyAttendanceUiState = AttendanceUiState(
  isHoliday: true,
  hasClockIn: false,
);
