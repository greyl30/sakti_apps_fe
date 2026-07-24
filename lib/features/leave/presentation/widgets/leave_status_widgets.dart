import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/leave_request_status.dart';

class LeaveStatusCard extends StatelessWidget {
  const LeaveStatusCard({super.key, required this.data});

  final LeaveRequestStatusData data;

  @override
  Widget build(BuildContext context) {
    final title = _statusTitle(data);
    final subtitle = _statusSubtitle(data);
    final color = _statusColor(data.status);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC6E6F0)),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            _statusIcon(data.status),
            width: 30,
            height: 30,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6E7480),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LeaveDetailCard extends StatelessWidget {
  const LeaveDetailCard({super.key, required this.data});

  final LeaveRequestStatusData data;

  @override
  Widget build(BuildContext context) {
    return _StatusSectionCard(
      title: 'DETAIL PENGAJUAN',
      children: [
        LeaveInfoRow(
          icon: AppAssets.iconCalendar,
          label: 'Tanggal Mulai',
          value: _formatLongDate(data.startDate),
        ),
        LeaveInfoRow(
          icon: AppAssets.iconCalendar,
          label: 'Tanggal Selesai',
          value: _formatLongDate(data.endDate),
        ),
        LeaveInfoRow(
          icon: AppAssets.iconDurasi,
          label: 'Durasi',
          value: '${data.totalDays} hari kerja',
        ),
        LeaveInfoRow(
          icon: AppAssets.iconAlasan,
          label: 'Keterangan',
          value: data.reason,
        ),
      ],
    );
  }
}

class LeaveApprovalTimelineCard extends StatelessWidget {
  const LeaveApprovalTimelineCard({super.key, required this.data});

  final LeaveRequestStatusData data;

  @override
  Widget build(BuildContext context) {
    final items = _timelineItems(data);

    return _StatusSectionCard(
      title: 'ALUR PERSETUJUAN',
      children: [
        for (var index = 0; index < items.length; index++)
          _TimelineItem(
            title: items[index].title,
            subtitle: items[index].subtitle,
            state: items[index].state,
            showLine: index != items.length - 1,
          ),
      ],
    );
  }
}

class _TimelineData {
  const _TimelineData({
    required this.title,
    required this.subtitle,
    required this.state,
  });

  final String title;
  final String subtitle;
  final _TimelineState state;
}

class LeaveInfoRow extends StatelessWidget {
  const LeaveInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset(
              icon,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                AppColors.secondaryBlue,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF8A8F98),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusSectionCard extends StatelessWidget {
  const _StatusSectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E8EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8A8F98),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

enum _TimelineState { done, active, pending, failed }

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.state,
    required this.showLine,
  });

  final String title;
  final String subtitle;
  final _TimelineState state;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    final isDone = state == _TimelineState.done;
    final isActive = state == _TimelineState.active;
    final isFailed = state == _TimelineState.failed;
    final color = isFailed
        ? AppColors.primaryRed
        : isDone || isActive
        ? AppColors.primaryRed
        : const Color(0xFFC9D0D8);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDone ? color : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: isDone
                  ? SvgPicture.asset(
                      AppAssets.iconCheck,
                      width: 10,
                      height: 10,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    )
                  : null,
            ),
            if (showLine)
              Container(
                width: 2,
                height: 34,
                color: color.withValues(alpha: .45),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: showLine ? 14 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: state == _TimelineState.pending
                        ? const Color(0xFFB1B7C0)
                        : Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF9AA0AA),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _statusTitle(LeaveRequestStatusData data) {
  return switch (data.status) {
    LeaveApprovalStatus.waitingSupervisor => 'Menunggu Atasan',
    LeaveApprovalStatus.waitingHRD => 'Menunggu HRD',
    LeaveApprovalStatus.approved => 'Disetujui',
    LeaveApprovalStatus.rejected => 'Ditolak',
    LeaveApprovalStatus.canceled => 'Dibatalkan',
  };
}

String _statusSubtitle(LeaveRequestStatusData data) {
  return switch (data.status) {
    LeaveApprovalStatus.waitingSupervisor =>
      'Dikirim: ${_formatDate(data.submittedDate)}',
    LeaveApprovalStatus.waitingHRD => 'Menunggu finalisasi HRD',
    LeaveApprovalStatus.approved => 'Pengajuan selesai',
    LeaveApprovalStatus.rejected => 'Pengajuan tidak disetujui',
    LeaveApprovalStatus.canceled => 'Pengajuan telah dibatalkan',
  };
}

String _statusIcon(LeaveApprovalStatus status) {
  return switch (status) {
    LeaveApprovalStatus.approved => AppAssets.iconCheck,
    LeaveApprovalStatus.rejected ||
    LeaveApprovalStatus.canceled => AppAssets.iconNo,
    LeaveApprovalStatus.waitingSupervisor ||
    LeaveApprovalStatus.waitingHRD => AppAssets.iconPending,
  };
}

Color _statusColor(LeaveApprovalStatus status) {
  return switch (status) {
    LeaveApprovalStatus.approved => AppColors.secondaryBlue,
    LeaveApprovalStatus.rejected ||
    LeaveApprovalStatus.canceled => AppColors.primaryRed,
    LeaveApprovalStatus.waitingSupervisor ||
    LeaveApprovalStatus.waitingHRD => AppColors.secondaryBlue,
  };
}

bool _hasSupervisorApproved(LeaveRequestStatusData data) {
  return data.progress == ApprovalProgress.waitingHRD ||
      data.progress == ApprovalProgress.approved ||
      data.supervisorApprovalDate != null;
}

List<_TimelineData> _timelineItems(LeaveRequestStatusData data) {
  final items = <_TimelineData>[
    _TimelineData(
      title: 'Pengajuan Dikirim',
      subtitle: _formatDateTime(data.submittedDate),
      state: _TimelineState.done,
    ),
  ];

  if (data.status == LeaveApprovalStatus.rejected) {
    if (_hasSupervisorApproved(data)) {
      items.add(_supervisorApprovedTimeline(data));
    }

    items.add(
      _TimelineData(
        title: 'Pengajuan Ditolak',
        subtitle: _terminalStatusSubtitle(data.statusUpdatedDate),
        state: _TimelineState.failed,
      ),
    );
    return items;
  }

  if (data.status == LeaveApprovalStatus.canceled) {
    if (_hasSupervisorApproved(data)) {
      items.add(_supervisorApprovedTimeline(data));
    }

    items.add(
      _TimelineData(
        title: 'Pengajuan Dibatalkan',
        subtitle: _terminalStatusSubtitle(data.cancelledDate),
        state: _TimelineState.failed,
      ),
    );
    return items;
  }

  if (data.progress == ApprovalProgress.waitingSupervisor ||
      data.progress == ApprovalProgress.submitted) {
    items.add(
      const _TimelineData(
        title: 'Menunggu Persetujuan Atasan',
        subtitle: 'Dalam proses',
        state: _TimelineState.active,
      ),
    );
    items.add(
      const _TimelineData(
        title: 'Menunggu Konfirmasi HRD',
        subtitle: 'Belum dimulai',
        state: _TimelineState.pending,
      ),
    );
    items.add(
      const _TimelineData(
        title: 'Pengajuan Cuti Berhasil',
        subtitle: 'Belum dimulai',
        state: _TimelineState.pending,
      ),
    );
    return items;
  }

  if (_hasSupervisorApproved(data)) {
    items.add(_supervisorApprovedTimeline(data));
  }

  if (data.progress == ApprovalProgress.waitingHRD) {
    items.add(
      const _TimelineData(
        title: 'Menunggu Konfirmasi HRD',
        subtitle: 'Dalam proses',
        state: _TimelineState.active,
      ),
    );
    items.add(
      const _TimelineData(
        title: 'Pengajuan Cuti Berhasil',
        subtitle: 'Belum dimulai',
        state: _TimelineState.pending,
      ),
    );
    return items;
  }

  if (data.progress == ApprovalProgress.approved) {
    items.add(
      _TimelineData(
        title: 'Pengajuan Cuti Berhasil',
        subtitle: data.hrdApprovalDate == null
            ? 'Selesai'
            : '${data.hrdName} - ${_formatTime(data.hrdApprovalDate!)}',
        state: _TimelineState.done,
      ),
    );
  }

  return items;
}

_TimelineData _supervisorApprovedTimeline(LeaveRequestStatusData data) {
  return _TimelineData(
    title: 'Disetujui Atasan',
    subtitle: data.supervisorApprovalDate == null
        ? 'Disetujui'
        : '${data.supervisorName} - ${_formatTime(data.supervisorApprovalDate!)}',
    state: _TimelineState.done,
  );
}

String _terminalStatusSubtitle(DateTime? date) {
  if (date == null) return 'Selesai';
  return _formatDateTime(date);
}

String _formatLongDate(DateTime date) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _formatDateTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${_formatDate(date)} - $hour:$minute';
}

String _formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
