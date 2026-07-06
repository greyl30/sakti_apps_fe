import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_assets.dart';
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
      height: 98,
      padding: const EdgeInsets.fromLTRB(14, 18, 24, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradientTop, AppColors.gradientBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
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
            icon: SvgPicture.asset(
              AppAssets.iconBack,
              width: 40.36,
              height: 40.36,
            ),
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
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
