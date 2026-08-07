import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../history/presentation/models/attendance_history_model.dart';
import '../../../history/presentation/providers/attendance_history_provider.dart';

/// Widget riwayat presensi terbaru dari backend.
class HomeHistorySection extends ConsumerWidget {
  const HomeHistorySection({super.key, required this.onSeeAllTap});

  final VoidCallback onSeeAllTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historiesAsync = ref.watch(attendanceHistoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Riwayat Presensi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            TextButton(
              onPressed: onSeeAllTap,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Lihat semua',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        historiesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryRed,
                strokeWidth: 3,
              ),
            ),
          ),
          error: (error, stackTrace) =>
              _HistoryMessage(message: error.toString()),
          data: (histories) {
            debugPrint(
              '[AttendanceHistory] home section received count: '
              '${histories.length}',
            );
            final latestHistories = histories.take(3).toList();
            if (latestHistories.isEmpty) {
              return const _HistoryMessage(
                message: 'Belum ada riwayat presensi',
              );
            }

            return Column(
              children: latestHistories
                  .map(
                    (history) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _HistoryCard(history: history),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.history});

  final AttendanceHistoryModel history;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.gray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDate(history.date),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _HistoryTime(
                  icon: AppAssets.iconIn,
                  iconBackground: const Color(0xFFEAFBFF),
                  iconColor: AppColors.secondaryBlue,
                  label: 'Presensi Masuk',
                  time: history.clockInLabel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HistoryTime(
                  icon: AppAssets.iconLogout,
                  iconBackground: const Color(0xFFFFF1F0),
                  iconColor: AppColors.primaryRed,
                  label: 'Presensi Keluar',
                  time: history.clockOutLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryTime extends StatelessWidget {
  const _HistoryTime({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.label,
    required this.time,
  });

  final String icon;
  final Color iconBackground;
  final Color iconColor;
  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SvgPicture.asset(
            icon,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF858585),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time == '-' ? '-' : '$time WIB',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF8A8F98),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
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

  return '${days[date.weekday - 1]}, ${date.day} '
      '${months[date.month - 1]} ${date.year}';
}
