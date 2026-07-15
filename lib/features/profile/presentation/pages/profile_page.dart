import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/profile_action_card.dart';
import '../widgets/profile_confirmation_dialog.dart';
import '../widgets/profile_data_card.dart';
import '../widgets/profile_header.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO(Backend):
    // Ambil data profile karyawan dari API.
    const employeeName = 'Wijaya Kusuma';
    const employeeStatus = 'Karyawan Aktif';
    const position = 'Staff IT & Infrastruktur';
    const division = 'Divisi Teknologi Informasi';
    const email = 'wijaya.kusuma@kopgetel.co.id';
    const phone = '+62 812-3456-7890';

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header profile dengan foto overlap seperti desain.
            const ProfileHeader(name: employeeName, status: employeeStatus),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 32),
              child: Column(
                children: [
                  // Card data diri karyawan.
                  const ProfileDataCard(
                    items: [
                      ProfileDataItem(
                        icon: AppAssets.jabatan,
                        label: 'Jabatan',
                        value: position,
                      ),
                      ProfileDataItem(
                        icon: AppAssets.divisi,
                        label: 'Divisi',
                        value: division,
                      ),
                      ProfileDataItem(
                        icon: AppAssets.email,
                        label: 'Email',
                        value: email,
                      ),
                      ProfileDataItem(
                        icon: AppAssets.telp,
                        label: 'No. HP',
                        value: phone,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  // Menu ubah password.
                  ProfileActionCard(
                    icon: AppAssets.reset,
                    title: 'Ubah Password',
                    subtitle: 'Ubah kata sandi akun Anda',
                    onTap: () => context.push(RouteName.changePassword),
                  ),
                  const SizedBox(height: 16),
                  // Menu logout.
                  ProfileActionCard(
                    icon: AppAssets.iconLogout,
                    title: 'Keluar',
                    subtitle: 'Keluar dari akun Anda',
                    onTap: () => _showLogoutDialog(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ProfileConfirmationDialog(
        icon: AppAssets.out,
        title: 'Apakah Anda yakin ingin keluar dari aplikasi ini?',
        confirmText: 'Ya',
        cancelText: 'Tidak',
        onConfirm: () {
          Navigator.of(dialogContext).pop();
          ref.read(authProvider.notifier).logout();
          context.go(RouteName.login);
        },
        onCancel: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }
}
