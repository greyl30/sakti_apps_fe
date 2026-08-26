import '../../../../core/utils/date_time_utils.dart';
import '../../presentation/models/manager_leave_approval.dart';

class ManagerLeaveApprovalModel {
  const ManagerLeaveApprovalModel({
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
    required this.directlyFinal,
    required this.employeeName,
    this.remainingLeave,
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
    this.employeeDivision,
    this.employeeUnit,
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
  final bool directlyFinal;
  final int? remainingLeave;
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
  final String employeeName;
  final String? employeeDivision;
  final String? employeeUnit;

  factory ManagerLeaveApprovalModel.fromJson(Map<String, dynamic> json) {
    return ManagerLeaveApprovalModel(
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
      directlyFinal: _readBool(json['langsung_final']),
      remainingLeave: _readNullableInt(json['sisa_cuti']),
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
      employeeName: _readString(json['karyawan_nama']),
      employeeDivision: _readNullableString(json['karyawan_divisi']),
      employeeUnit: _readNullableString(json['karyawan_unit']),
    );
  }

  ManagerLeaveApproval toPresentationModel() {
    return ManagerLeaveApproval(
      id: id,
      employeeName: employeeName.isEmpty ? '-' : employeeName,
      division: _formatEmployeeOrganization(
        division: employeeDivision,
        unit: employeeUnit,
      ),
      type: _mapSubType(subType),
      startDate: startDate,
      endDate: endDate,
      remainingLeave: remainingLeave,
      reason: reason.isEmpty ? _mapSubTypeLabel(subType) : reason,
      totalDaysOverride: totalDays,
    );
  }
}

ManagerApprovalType _mapSubType(String value) {
  switch (value.trim().toLowerCase()) {
    case 'sakit':
      return ManagerApprovalType.sickLeave;
    case 'dispensasi':
      return ManagerApprovalType.dispensation;
    case 'izin':
    default:
      return ManagerApprovalType.permission;
  }
}

String _mapSubTypeLabel(String value) {
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

String _formatEmployeeOrganization({String? division, String? unit}) {
  final parts = [
    if (division != null && division.trim().isNotEmpty) division.trim(),
    if (unit != null && unit.trim().isNotEmpty) unit.trim(),
  ];

  if (parts.isEmpty) return '-';
  return parts.join(' / ');
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

int? _readNullableInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();

  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return int.tryParse(text);
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
  return parseBackendDateTime(value);
}
