import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget riwayat
/// Menampilkan tiga data presensi dummy terakhir.
class HomeHistorySection extends StatelessWidget {
  const HomeHistorySection({super.key, required this.onSeeAllTap});

  final VoidCallback onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    final histories = [
      _HistoryItem('Jumat, 5 Juli 2025', '08:00', '17:03'),
      _HistoryItem('Kamis, 4 Juli 2025', '07:48', '17:15'),
      _HistoryItem('Rabu, 3 Juli 2025', '07:55', '16:58'),
    ];

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
        ...histories.map(
          (history) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _HistoryCard(history: history),
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.history});

  final _HistoryItem history;

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
            history.date,
            style: const TextStyle(
              fontSize: 13,
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
                  time: history.checkIn,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HistoryTime(
                  icon: AppAssets.iconLogout,
                  iconBackground: const Color(0xFFFFF1F0),
                  iconColor: AppColors.primaryRed,
                  label: 'Presensi Keluar',
                  time: history.checkOut,
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
          width: 32,
          height: 32,
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
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF858585),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
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

class _HistoryItem {
  const _HistoryItem(this.date, this.checkIn, this.checkOut);

  final String date;
  final String checkIn;
  final String checkOut;
}
