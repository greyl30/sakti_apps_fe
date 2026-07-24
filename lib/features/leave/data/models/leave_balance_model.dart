class LeaveBalanceModel {
  const LeaveBalanceModel({
    required this.year,
    required this.totalLeave,
    required this.usedLeave,
    required this.scheduledLeave,
    required this.remainingLeave,
    required this.previousYearRemainingLeave,
    required this.availableRequestQuota,
  });

  final int year;
  final int totalLeave;
  final int usedLeave;
  final int scheduledLeave;
  final int remainingLeave;
  final int previousYearRemainingLeave;
  final int availableRequestQuota;

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceModel(
      year: _readInt(json['tahun']),
      totalLeave: _readInt(json['jumlah_cuti'] ?? json['total_cuti_tersedia']),
      usedLeave: _readInt(json['telah_dilaksanakan']),
      scheduledLeave: _readInt(json['akan_dilaksanakan']),
      remainingLeave: _readInt(json['sisa_cuti']),
      previousYearRemainingLeave: _readInt(json['sisa_cuti_tahun_lalu']),
      availableRequestQuota: _readInt(json['kuota_pengajuan_tersedia']),
    );
  }
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
