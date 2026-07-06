import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/route_name.dart';
import '../theme/app_colors.dart';

/// Reusable top navigation bar
/// Digunakan pada seluruh halaman selain homepage
class CustomTopBar extends StatelessWidget {
  const CustomTopBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 106,
      padding: const EdgeInsets.fromLTRB(14, 18, 24, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradientTop, AppColors.gradientBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RouteName.home);
              }
            },
            icon: const Icon(Icons.chevron_left_rounded),
            color: Colors.white,
            iconSize: 34,
            tooltip: 'Kembali',
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
