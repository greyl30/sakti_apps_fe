import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/home_role.dart';
import '../models/hrd_leave_finalization.dart';
import '../models/manager_leave_approval.dart';
import '../providers/hrd_leave_finalization_provider.dart';
import '../providers/manager_leave_approval_provider.dart';

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

class ManagerHomeSection extends ConsumerWidget {
  const ManagerHomeSection({
    super.key,
    required this.onSeeAllTap,
    required this.onItemTap,
  });

  final VoidCallback onSeeAllTap;
  final VoidCallback onItemTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approvals = ref.watch(managerPendingLeaveApprovalsProvider);

    return approvals.when(
      data: (items) {
        final visibleItems = items.take(3).toList();
        return _RoleRequestCard(
          title: 'Setujui Cuti',
          pendingCount: items.length,
          items: [
            for (final item in visibleItems)
              _homeApprovalItemFromApproval(item),
          ],
          emptyMessage: 'Tidak ada pengajuan cuti',
          onSeeAllTap: onSeeAllTap,
          onItemTap: onItemTap,
        );
      },
      loading: () => _RoleRequestCard(
        title: 'Setujui Cuti',
        pendingCount: 0,
        items: const [],
        emptyMessage: 'Memuat pengajuan cuti...',
        onSeeAllTap: onSeeAllTap,
        onItemTap: onItemTap,
      ),
      error: (error, stackTrace) => _RoleRequestCard(
        title: 'Setujui Cuti',
        pendingCount: 0,
        items: const [],
        emptyMessage: 'Pengajuan cuti belum dapat dimuat.',
        onSeeAllTap: onSeeAllTap,
        onItemTap: onItemTap,
      ),
    );
  }
}

class HrdHomeSection extends ConsumerWidget {
  const HrdHomeSection({
    super.key,
    required this.onSeeAllTap,
    required this.onItemTap,
  });

  final VoidCallback onSeeAllTap;
  final VoidCallback onItemTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finalizations = ref.watch(hrdPendingLeaveFinalizationsProvider);

    return finalizations.when(
      data: (items) {
        final visibleItems = items.take(3).toList();
        return _RoleRequestCard(
          title: 'Finalisasi Cuti',
          pendingCount: items.length,
          items: [
            for (final item in visibleItems)
              _homeFinalizationItemFromFinalization(item),
          ],
          emptyMessage: 'Tidak ada finalisasi cuti',
          onSeeAllTap: onSeeAllTap,
          onItemTap: onItemTap,
        );
      },
      loading: () => _RoleRequestCard(
        title: 'Finalisasi Cuti',
        pendingCount: 0,
        items: const [],
        emptyMessage: 'Memuat finalisasi cuti...',
        onSeeAllTap: onSeeAllTap,
        onItemTap: onItemTap,
      ),
      error: (error, stackTrace) => _RoleRequestCard(
        title: 'Finalisasi Cuti',
        pendingCount: 0,
        items: const [],
        emptyMessage: 'Finalisasi cuti belum dapat dimuat.',
        onSeeAllTap: onSeeAllTap,
        onItemTap: onItemTap,
      ),
    );
  }
}

class _RoleRequestCard extends StatelessWidget {
  const _RoleRequestCard({
    required this.title,
    required this.pendingCount,
    required this.items,
    required this.emptyMessage,
    required this.onSeeAllTap,
    required this.onItemTap,
  });

  final String title;
  final int pendingCount;
  final List<HomeApprovalItem> items;
  final String emptyMessage;
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
          // Header role section, count berasal dari backend.
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  pendingCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
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
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            _RoleRequestEmptyMessage(message: emptyMessage)
          else
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

class _RoleRequestEmptyMessage extends StatelessWidget {
  const _RoleRequestEmptyMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF8A8F98),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}

HomeApprovalItem _homeApprovalItemFromApproval(ManagerLeaveApproval approval) {
  return HomeApprovalItem(
    employeeName: approval.employeeName,
    requestType: managerApprovalTypeLabel(approval.type),
    dateRange:
        '${_formatShortDateRange(approval.startDate, approval.endDate)}'
        ' - ${approval.totalDays} hari',
  );
}

HomeApprovalItem _homeFinalizationItemFromFinalization(
  HrdLeaveFinalization finalization,
) {
  return HomeApprovalItem(
    employeeName: finalization.employeeName,
    requestType: managerApprovalTypeLabel(finalization.type),
    dateRange:
        '${_formatShortDateRange(finalization.startDate, finalization.endDate)}'
        ' - ${finalization.totalDays} hari',
  );
}

String _formatShortDateRange(DateTime startDate, DateTime endDate) {
  if (_isSameDay(startDate, endDate)) return _formatShortDate(startDate);
  return '${startDate.day} - ${_formatShortDate(endDate)}';
}

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

String _formatShortDate(DateTime date) {
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
  return '${date.day} ${months[date.month - 1]}';
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
          height: 34,
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
                    fontSize: 13,
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
                  fontSize: 13,
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
