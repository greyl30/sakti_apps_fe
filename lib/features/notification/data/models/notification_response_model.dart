import '../../../../core/utils/date_time_utils.dart';
import '../../presentation/models/notification_model.dart';

class NotificationResponseModel {
  const NotificationResponseModel({
    required this.id,
    required this.type,
    required this.channel,
    required this.title,
    required this.message,
    required this.isRead,
    this.readAt,
    this.referenceId,
    this.referenceType,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String channel;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? readAt;
  final String? referenceId;
  final String? referenceType;
  final DateTime createdAt;

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationResponseModel(
      id: _readString(json['id']),
      type: _readString(json['jenis']),
      channel: _readString(json['channel']),
      title: _readString(json['judul']),
      message: _readString(json['pesan']),
      isRead: _readBool(json['dibaca']),
      readAt: _readNullableDate(json['dibaca_pada']),
      referenceId: _readNullableString(json['referensi_id']),
      referenceType: _readNullableString(json['referensi_tipe']),
      createdAt: _readNullableDate(json['dibuat_pada']) ?? DateTime.now(),
    );
  }

  NotificationModel toPresentationModel() {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: _mapNotificationType(type),
      createdAt: createdAt,
      isRead: isRead,
    );
  }
}

NotificationType _mapNotificationType(String value) {
  final normalized = value.trim().toLowerCase();

  if (normalized.contains('check_in') ||
      normalized.contains('check-in') ||
      normalized.contains('masuk')) {
    return NotificationType.checkIn;
  }

  if (normalized.contains('check_out') ||
      normalized.contains('check-out') ||
      normalized.contains('keluar')) {
    return NotificationType.checkOut;
  }

  if (normalized.contains('dispensasi')) {
    return NotificationType.dispensationRequest;
  }

  if (normalized.contains('darurat')) {
    return NotificationType.emergencyLeaveRequest;
  }

  if (normalized.contains('approved') ||
      normalized.contains('disetujui') ||
      normalized.contains('final')) {
    return NotificationType.leaveApproved;
  }

  if (normalized.contains('rejected') || normalized.contains('ditolak')) {
    return NotificationType.rejected;
  }

  if (normalized.contains('libur') || normalized.contains('holiday')) {
    return NotificationType.holiday;
  }

  return NotificationType.leaveRequest;
}

String _readString(Object? value) {
  return value?.toString() ?? '';
}

String? _readNullableString(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return text;
}

bool _readBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;

  final normalized = value?.toString().trim().toLowerCase();
  return normalized == 'true' || normalized == '1' || normalized == 'ya';
}

DateTime? _readNullableDate(Object? value) {
  return parseBackendDateTime(value);
}
