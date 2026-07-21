import 'package:sakti_apps_fe/features/leave/presentation/models/leave_form_data.dart';
import 'package:sakti_apps_fe/features/leave/presentation/models/leave_history_model.dart';
import 'package:sakti_apps_fe/features/leave/presentation/models/leave_request_status.dart';

class LeaveRequestModel {
  const LeaveRequestModel({
    required this.subType,
    required this.startDate,
    required this.endDate,
    required this.reason,
  });

  final String subType;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;

  factory LeaveRequestModel.fromFormData(LeaveFormData data) {
    return LeaveRequestModel(
      subType: _mapPresentationTypeToApi(data.type),
      startDate: data.startDate,
      endDate: data.endDate,
      reason: data.reason,
    );
  }

  // Request body untuk POST /api/leave/request.
  Map<String, dynamic> toJson() {
    return {
      'sub_tipe': subType,
      'tanggal_mulai': _formatDate(startDate),
      'tanggal_selesai': _formatDate(endDate),
      'alasan': reason,
    };
  }
}

class LeaveRequestResponse {
  const LeaveRequestResponse({
    required this.id,
    required this.employeeId,
    required this.subType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    required this.status,
    required this.backDate,
    required this.deductsLeave,
    required this.directlyApproved,
    this.documentTitle,
    this.approvedBy,
    this.approvedAt,
    this.finalizedBy,
    this.finalizedAt,
    this.pdfUrl,
    this.cancelReason,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String employeeId;
  final String subType;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String reason;
  final String status;
  final bool backDate;
  final bool deductsLeave;
  final bool directlyApproved;
  final String? documentTitle;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? finalizedBy;
  final DateTime? finalizedAt;
  final String? pdfUrl;
  final String? cancelReason;
  final DateTime? cancelledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory LeaveRequestResponse.fromJson(Map<String, dynamic> json) {
    return LeaveRequestResponse(
      id: _readString(json['id']),
      employeeId: _readString(json['karyawan_id']),
      subType: _readString(json['sub_tipe']),
      startDate: _readDate(json['tanggal_mulai']),
      endDate: _readDate(json['tanggal_selesai']),
      totalDays: _readInt(json['total_hari']),
      reason: _readString(json['alasan']),
      status: _readString(json['status']),
      backDate: _readBool(json['back_date']),
      deductsLeave: _readBool(json['mengurangi_cuti']),
      directlyApproved: _readBool(json['langsung_approve']),
      documentTitle: _readNullableString(json['judul_dokumen']),
      approvedBy: _readNullableString(json['disetujui_oleh']),
      approvedAt: _readNullableDate(json['tanggal_disetujui']),
      finalizedBy: _readNullableString(json['difinalisasi_oleh']),
      finalizedAt: _readNullableDate(json['tanggal_difinalisasi']),
      pdfUrl: _readNullableString(json['url_pdf']),
      cancelReason: _readNullableString(json['alasan_batal']),
      cancelledAt: _readNullableDate(json['tanggal_dibatalkan']),
      createdAt: _readNullableDate(json['dibuat_pada']),
      updatedAt: _readNullableDate(json['diperbarui_pada']),
    );
  }

  factory LeaveRequestResponse.fromApiResponse(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is Map<String, dynamic>
        ? rawData
        : Map<String, dynamic>.from(rawData as Map? ?? {});

    return LeaveRequestResponse.fromJson(data);
  }

  String get presentationType => _mapApiTypeToPresentation(subType);

  LeaveApprovalStatus get approvalStatus {
    return _mapApiStatusToApprovalStatus(status);
  }

  ApprovalProgress get approvalProgress {
    return _mapApiStatusToApprovalProgress(status);
  }

  LeaveApprovalStage get approvalStage {
    return approvalProgress == ApprovalProgress.waitingHRD ||
            approvalProgress == ApprovalProgress.approved
        ? LeaveApprovalStage.currentHRD
        : LeaveApprovalStage.currentSupervisor;
  }

  LeaveHistoryStatus get historyStatus {
    return _mapApiStatusToHistoryStatus(status);
  }

  LeaveRequestStatusData toStatusData({
    String fallbackSupervisorName = '-',
    String fallbackHrdName = 'HRD',
  }) {
    // Mapper sementara agar response API dapat memakai widget status yang ada.
    return LeaveRequestStatusData(
      type: presentationType,
      reason: reason,
      startDate: startDate,
      endDate: endDate,
      submittedDate: createdAt ?? updatedAt ?? startDate,
      supervisorName: approvedBy ?? fallbackSupervisorName,
      hrdName: finalizedBy ?? fallbackHrdName,
      stage: approvalStage,
      status: approvalStatus,
      progress: approvalProgress,
      supervisorApprovalDate: approvedAt,
      hrdApprovalDate: finalizedAt,
    );
  }

  LeaveHistoryModel toHistoryModel() {
    // Mapper riwayat untuk reuse card/list history yang sudah tersedia.
    return LeaveHistoryModel(
      id: id,
      leaveType: presentationType,
      startDate: startDate,
      endDate: endDate,
      status: historyStatus,
    );
  }
}

String _formatDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

String _mapPresentationTypeToApi(String value) {
  switch (value.trim().toLowerCase()) {
    case 'sakit':
      return 'sakit';
    case 'dispensasi':
      return 'dispensasi';
    case 'izin':
    default:
      return 'izin';
  }
}

String _mapApiTypeToPresentation(String value) {
  switch (value.trim().toLowerCase()) {
    case 'sakit':
      return 'Sakit';
    case 'dispensasi':
      return 'Dispensasi';
    case 'izin':
    default:
      return 'Izin';
  }
}

LeaveApprovalStatus _mapApiStatusToApprovalStatus(String value) {
  final normalized = value.trim().toLowerCase();

  if (normalized == 'approved' ||
      normalized == 'disetujui' ||
      normalized == 'finalized' ||
      normalized == 'difinalisasi') {
    return LeaveApprovalStatus.approved;
  }

  if (normalized == 'waiting_hrd' ||
      normalized == 'menunggu_hrd' ||
      normalized == 'approved_by_supervisor' ||
      normalized == 'disetujui_atasan') {
    return LeaveApprovalStatus.waitingHRD;
  }

  return LeaveApprovalStatus.waitingSupervisor;
}

ApprovalProgress _mapApiStatusToApprovalProgress(String value) {
  final normalized = value.trim().toLowerCase();

  if (normalized == 'approved' ||
      normalized == 'disetujui' ||
      normalized == 'finalized' ||
      normalized == 'difinalisasi') {
    return ApprovalProgress.approved;
  }

  if (normalized == 'waiting_hrd' ||
      normalized == 'menunggu_hrd' ||
      normalized == 'approved_by_supervisor' ||
      normalized == 'disetujui_atasan') {
    return ApprovalProgress.waitingHRD;
  }

  if (normalized == 'submitted' || normalized == 'diajukan') {
    return ApprovalProgress.submitted;
  }

  return ApprovalProgress.waitingSupervisor;
}

LeaveHistoryStatus _mapApiStatusToHistoryStatus(String value) {
  final normalized = value.trim().toLowerCase();

  if (normalized == 'rejected' ||
      normalized == 'ditolak' ||
      normalized == 'cancelled' ||
      normalized == 'dibatalkan') {
    return LeaveHistoryStatus.rejected;
  }

  return LeaveHistoryStatus.approved;
}

String _readString(Object? value) {
  return value?.toString() ?? '';
}

String? _readNullableString(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return text;
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _readBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;

  final normalized = value?.toString().trim().toLowerCase();
  return normalized == 'true' || normalized == '1' || normalized == 'ya';
}

DateTime _readDate(Object? value) {
  return _readNullableDate(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
}

DateTime? _readNullableDate(Object? value) {
  if (value is DateTime) return value;

  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;

  return DateTime.tryParse(text);
}
