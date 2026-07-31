import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../leave/presentation/widgets/leave_list_item.dart';
import '../../../leave/presentation/widgets/leave_success_widgets.dart';

class TelegramSuccessPage extends StatelessWidget {
  const TelegramSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 110, 24, 28),
          children: [
            const LeaveSuccessHeader(
              title: 'Telegram Berhasil Terhubung',
              description:
                  'Akun Telegram Anda telah berhasil dihubungkan dengan aplikasi SAKTI.',
            ),
            const SizedBox(height: 28),
            LeavePrimaryButton(
              label: 'Kembali',
              onPressed: () => context.go(RouteName.profile),
            ),
          ],
        ),
      ),
    );
  }
}
