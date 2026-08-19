enum AttendanceFlowType {
  checkIn,
  checkOut;

  bool get isCheckIn => this == AttendanceFlowType.checkIn;

  String get verificationSubtitle => 'Verifikasi wajah dan lokasi';

  String get successTitle =>
      isCheckIn ? 'Presensi Masuk Berhasil!' : 'Presensi Keluar Berhasil!';

  String get successRecordedLabel =>
      isCheckIn ? 'Presensi Masuk Tercatat' : 'Jam Keluar Tercatat';
}
