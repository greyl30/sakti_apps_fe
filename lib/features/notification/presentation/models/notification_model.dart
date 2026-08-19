enum NotificationType {
  checkIn,
  checkOut,
  leaveRequest,
  dispensationRequest,
  emergencyLeaveRequest,
  leaveApproved,
  rejected,
  holiday,
}

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

// TODO(Backend):
// Backend akan mengirim:
// - title
// - message
// - type
// - createdAt
// - isRead
//
// Frontend hanya menampilkan data yang diterima.
final dummyEmployeeNotifications = [
  NotificationModel(
    id: 'notif-employee-leave-approved',
    title: 'Pengajuan cuti berhasil',
    message:
        'Pengajuan cuti Anda telah disetujui dan difinalisasi. Surat cuti Anda telah tersedia dan dapat diunduh pada halaman Cuti.',
    type: NotificationType.leaveApproved,
    createdAt: DateTime(2026, 7, 13, 8, 10),
    isRead: false,
  ),
  NotificationModel(
    id: 'notif-employee-check-in',
    title: 'Presensi Masuk',
    message:
        'Segera lakukan presensi masuk. Jika melewati batas tepat waktu, presensi akan dihitung sebagai terlambat.',
    type: NotificationType.checkIn,
    createdAt: DateTime(2026, 7, 14, 9),
    isRead: false,
  ),
  NotificationModel(
    id: 'notif-employee-check-out',
    title: 'Presensi Keluar',
    message:
        'Segera lakukan presensi keluar. Jika sedang lembur, lakukan presensi sesuai waktu Anda pulang.',
    type: NotificationType.checkOut,
    createdAt: DateTime(2026, 7, 14, 14, 10),
    isRead: true,
  ),
  NotificationModel(
    id: 'notif-employee-rejected',
    title: 'Pengajuan Ditolak',
    message:
        'Pengajuan cuti Anda belum dapat disetujui. Silakan periksa detail pengajuan untuk melihat informasi lebih lanjut.',
    type: NotificationType.rejected,
    createdAt: DateTime(2026, 7, 12, 14, 20),
    isRead: true,
  ),
  NotificationModel(
    id: 'notif-employee-holiday',
    title: 'Hari Libur',
    message:
        'Hari ini adalah hari libur. Anda tidak perlu melakukan presensi masuk maupun presensi keluar.',
    type: NotificationType.holiday,
    createdAt: DateTime(2026, 7, 11, 7, 30),
    isRead: true,
  ),
];

final dummySupervisorNotifications = [
  NotificationModel(
    id: 'notif-supervisor-leave',
    title: 'Pengajuan Cuti',
    message:
        'Wijaya Kusuma mengajukan cuti dan menunggu persetujuan Anda. Silakan periksa detail pengajuan.',
    type: NotificationType.leaveRequest,
    createdAt: DateTime(2026, 7, 14, 10, 5),
    isRead: false,
  ),
  NotificationModel(
    id: 'notif-supervisor-dispensation',
    title: 'Pengajuan Dispensasi',
    message:
        'Ada pengajuan dispensasi baru dari karyawan yang perlu Anda tinjau.',
    type: NotificationType.dispensationRequest,
    createdAt: DateTime(2026, 7, 14, 9, 40),
    isRead: false,
  ),
  NotificationModel(
    id: 'notif-supervisor-emergency-leave',
    title: 'Pengajuan Cuti Darurat',
    message:
        'Pengajuan cuti darurat baru telah dikirim dan menunggu persetujuan atasan.',
    type: NotificationType.emergencyLeaveRequest,
    createdAt: DateTime(2026, 7, 13, 13, 10),
    isRead: true,
  ),
];

final dummyHrdNotifications = [
  NotificationModel(
    id: 'notif-hrd-leave-martin',
    title: 'Pengajuan cuti oleh Martin Habibuan',
    message:
        'Martin Habibuan telah mengajukan cuti berupa izin. Silahkan lakukan finalisasi pada halaman yang tersedia di Beranda Anda.',
    type: NotificationType.leaveRequest,
    createdAt: DateTime(2026, 7, 22, 10),
    isRead: false,
  ),
  NotificationModel(
    id: 'notif-hrd-leave-siti',
    title: 'Pengajuan cuti oleh Siti Nur Amalía',
    message:
        'Siti Nur Amalía telah mengajukan cuti berupa Cuti Sakit. Silahkan lakukan finalisasi pada halaman yang tersedia di Beranda Anda.',
    type: NotificationType.leaveRequest,
    createdAt: DateTime(2026, 7, 20, 10),
    isRead: true,
  ),
  NotificationModel(
    id: 'notif-hrd-leave-haeza',
    title: 'Pengajuan cuti oleh Haeza Jeremy Gideon',
    message:
        'Haeza Jeremy Gideon telah mengajukan cuti berupa izin. Silahkan lakukan finalisasi pada halaman yang tersedia di Beranda Anda.',
    type: NotificationType.leaveRequest,
    createdAt: DateTime(2026, 7, 10, 14, 27),
    isRead: true,
  ),
  NotificationModel(
    id: 'notif-hrd-check-in',
    title: 'Presensi Masuk',
    message:
        'Segera lakukan presensi masuk. Jika melewati batas tepat waktu, presensi akan dihitung sebagai terlambat.',
    type: NotificationType.checkIn,
    createdAt: DateTime(2026, 7, 17, 8),
    isRead: true,
  ),
  NotificationModel(
    id: 'notif-hrd-check-out',
    title: 'Presensi Keluar',
    message:
        'Segera lakukan presensi keluar. Jika sedang lembur, lakukan presensi sesuai waktu Anda pulang.',
    type: NotificationType.checkOut,
    createdAt: DateTime(2026, 7, 16, 17, 15),
    isRead: true,
  ),
];
