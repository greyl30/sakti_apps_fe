enum AttendanceFlowType {
  checkIn,
  checkOut;

  bool get isCheckIn => this == AttendanceFlowType.checkIn;

  String get verificationSubtitle => 'Verifikasi wajah dan lokasi';

  String get confirmationTitle => 'Konfirmasi Presensi';

  String get confirmationSubtitle => isCheckIn
      ? 'Konfirmasi presensi masuk Anda'
      : 'Konfirmasi presensi keluar Anda';

  String get summaryTitle =>
      isCheckIn ? 'RINGKASAN PRESENSI MASUK' : 'RINGKASAN PRESENSI KELUAR';

  String get confirmButtonLabel =>
      isCheckIn ? 'Konfirmasi Presensi Masuk' : 'Konfirmasi Presensi Keluar';

  String get successTitle =>
      isCheckIn ? 'Presensi Masuk Berhasil!' : 'Presensi Keluar Berhasil!';

  String get successRecordedLabel =>
      isCheckIn ? 'Presensi Masuk Tercatat' : 'Jam Keluar Tercatat';

  String get successTime => isCheckIn ? '08:00 WIB' : '17:05 WIB';
}
