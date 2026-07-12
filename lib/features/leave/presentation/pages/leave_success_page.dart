import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/leave_request_status.dart';
import '../widgets/leave_list_item.dart';
import '../widgets/leave_success_widgets.dart';

class LeaveSuccessPage extends StatelessWidget {
  const LeaveSuccessPage({super.key, required this.data});

  final LeaveRequestStatusData data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 54, 24, 28),
          children: [
            // Tombol kembali tanpa Top AppBar.
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => context.go(RouteName.leaveStatus, extra: data),
                customBorder: const CircleBorder(),
                child: SvgPicture.asset(AppAssets.back2, width: 40, height: 40),
              ),
            ),
            const SizedBox(height: 20),
            const LeaveSuccessHeader(
              title: 'Pengajuan Cuti Berhasil!',
              description:
                  'Cuti Anda telah disetujui dan tercatat dalam sistem',
              badge: 'DISETUJUI',
            ),
            const SizedBox(height: 28),
            // Ringkasan data pengajuan cuti.
            LeaveSummaryCard(data: data),
            const SizedBox(height: 28),
            LeavePrimaryButton(
              label: 'Unduh Surat Cuti',
              onPressed: () {
                // Backend nantinya akan mengirim file PDF surat cuti.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Download surat cuti akan dihubungkan dengan backend.',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            LeaveSecondaryButton(
              label: 'Batalkan Cuti',
              onPressed: () => context.push(RouteName.leaveCancel, extra: data),
            ),
          ],
        ),
      ),
    );
  }
}
