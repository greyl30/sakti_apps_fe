import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_assets.dart';
import '../router/route_name.dart';

/// Bottom navigation utama karyawan.
/// Hanya digunakan pada halaman Beranda, Presensi, Cuti, dan Darurat.
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({super.key, required this.currentIndex});

  final int currentIndex;

  static const _routes = [
    RouteName.home,
    RouteName.attendance,
    RouteName.leave,
    RouteName.emergency,
  ];

  @override
  Widget build(BuildContext context) {
    final items = [
      _BottomNavigationItem(AppAssets.iconHome, 'Beranda'),
      _BottomNavigationItem(AppAssets.iconAbsen, 'Presensi'),
      _BottomNavigationItem(AppAssets.iconCuti, 'Cuti'),
      _BottomNavigationItem(AppAssets.iconDarurat, 'Darurat'),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 70,
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == currentIndex;

            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  if (!isSelected) context.go(_routes[index]);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 44,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFDDD9)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: SvgPicture.asset(
                        item.icon,
                        width: 17,
                        height: 17,
                        colorFilter: ColorFilter.mode(
                          isSelected ? Colors.black : const Color(0xFF1D1D1F),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        height: 1,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _BottomNavigationItem {
  const _BottomNavigationItem(this.icon, this.label);

  final String icon;
  final String label;
}
