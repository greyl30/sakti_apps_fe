import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/home_role.dart';

class HomeRoleSection extends StatelessWidget {
  const HomeRoleSection({
    super.key,
    required this.role,
    required this.onSeeAllTap,
    required this.onItemTap,
  });

  final UserRole role;
  final VoidCallback onSeeAllTap;
  final VoidCallback onItemTap;

  @override
  Widget build(BuildContext context) {
    return switch (role) {
      UserRole.employee => const SizedBox.shrink(),
      UserRole.manager => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: ManagerHomeSection(
          onSeeAllTap: onSeeAllTap,
          onItemTap: onItemTap,
        ),
      ),
      UserRole.hrd => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: HrdHomeSection(
          onSeeAllTap: () => context.push(RouteName.hrdLeaveFinalizations),
          onItemTap: () => context.push(RouteName.hrdLeaveFinalizations),
        ),
      ),
    };
  }
}

class ManagerHomeSection extends StatelessWidget {
  const ManagerHomeSection({
    super.key,
    required this.onSeeAllTap,
    required this.onItemTap,
  });

  final VoidCallback onSeeAllTap;
  final VoidCallback onItemTap;

  @override
  Widget build(BuildContext context) {
    return _RoleRequestCard(
      title: 'Setujui Cuti',
      pendingCount: 12,
      items: dummyManagerApprovalItems,
      onSeeAllTap: onSeeAllTap,
      onItemTap: onItemTap,
    );
  }
}

class HrdHomeSection extends StatelessWidget {
  const HrdHomeSection({
    super.key,
    required this.onSeeAllTap,
    required this.onItemTap,
  });

  final VoidCallback onSeeAllTap;
  final VoidCallback onItemTap;

  @override
  Widget build(BuildContext context) {
    return _RoleRequestCard(
      title: 'Finalisasi Cuti',
      pendingCount: 12,
      items: dummyHrdFinalizationItems,
      onSeeAllTap: onSeeAllTap,
      onItemTap: onItemTap,
    );
  }
}

class _RoleRequestCard extends StatelessWidget {
  const _RoleRequestCard({
    required this.title,
    required this.pendingCount,
    required this.items,
    required this.onSeeAllTap,
    required this.onItemTap,
  });

  final String title;
  final int pendingCount;
  final List<HomeApprovalItem> items;
  final VoidCallback onSeeAllTap;
  final VoidCallback onItemTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 15, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E5EB),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header role section, nanti count berasal dari backend.
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  pendingCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
              TextButton(
                onPressed: onSeeAllTap,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondaryBlue,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Lihat semua',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(
            items.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                bottom: index == items.length - 1 ? 0 : 10,
              ),
              child: _RoleRequestItem(item: items[index], onTap: onItemTap),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleRequestItem extends StatelessWidget {
  const _RoleRequestItem({required this.item, required this.onTap});

  final HomeApprovalItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${item.employeeName} - (${item.requestType})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF5F6972),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                item.dateRange,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
