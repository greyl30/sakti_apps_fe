import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../leave/data/models/leave_request_model.dart';
import '../../../leave/presentation/models/leave_request_status.dart';
import '../../../leave/presentation/providers/leave_submit_provider.dart';
import '../../../leave/presentation/utils/leave_workday_calculator.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final holidays = ref.watch(activeLeaveHolidayDatesProvider);
    final leaveRequests = ref.watch(calendarLeaveRequestsProvider);
    final holidayDates = holidays.valueOrNull ?? const <DateTime>{};
    final requests =
        leaveRequests.valueOrNull ?? const <LeaveRequestResponse>[];
    final hasSupervisor = _hasSupervisor(
      ref.watch(authProvider).user?.atasanLangsungId,
    );
    final markers = _buildMarkers(holidayDates, requests);

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const LeaveTopBar(
              title: 'Kalender',
              subtitle: 'Jadwal libur, cuti, dan dispensasi',
              fallbackRoute: RouteName.home,
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryRed,
                onRefresh: _refreshCalendar,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                  children: [
                    _CalendarMonthHeader(
                      month: _visibleMonth,
                      onPreviousTap: () => _moveMonth(-1),
                      onNextTap: () => _moveMonth(1),
                    ),
                    const SizedBox(height: 18),
                    _CalendarGrid(
                      visibleMonth: _visibleMonth,
                      markers: markers,
                      isLoading:
                          (holidays.isLoading &&
                              holidays.valueOrNull == null) ||
                          (leaveRequests.isLoading &&
                              leaveRequests.valueOrNull == null),
                      onDateTap: (marker) => _openMarkerDetail(
                        marker,
                        hasSupervisor: hasSupervisor,
                      ),
                    ),
                    if (holidays.hasError || leaveRequests.hasError) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Data kalender belum dapat dimuat lengkap.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF8A8F98),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    const _CalendarLegend(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshCalendar() async {
    ref.invalidate(activeLeaveHolidayDatesProvider);
    ref.invalidate(calendarLeaveRequestsProvider);

    await Future.wait([
      _ignoreRefreshError(ref.read(activeLeaveHolidayDatesProvider.future)),
      _ignoreRefreshError(ref.read(calendarLeaveRequestsProvider.future)),
    ]);
  }

  Future<void> _ignoreRefreshError(Future<Object?> future) async {
    try {
      await future;
    } catch (_) {
      // Error state ditampilkan di halaman kalender.
    }
  }

  void _moveMonth(int offset) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + offset,
      );
    });
  }

  Map<DateTime, _CalendarMarker> _buildMarkers(
    Set<DateTime> holidays,
    List<LeaveRequestResponse> requests,
  ) {
    final markers = <DateTime, _CalendarMarker>{};
    final visibleMonthLabel = _formatMonth(_visibleMonth);

    for (final date in _monthDates(_visibleMonth)) {
      final normalized = normalizeLeaveDate(date);
      if (holidays.contains(normalized)) {
        markers[normalized] = const _CalendarMarker(
          type: _CalendarMarkerType.holiday,
        );
      } else if (_isWeekend(normalized)) {
        markers[normalized] = const _CalendarMarker(
          type: _CalendarMarkerType.weekend,
        );
      }
    }

    for (final request in requests) {
      final markerDecision = _requestMarkerDecision(request);
      if (_requestOverlapsMonth(request, _visibleMonth)) {
        debugPrint(
          '[CalendarMarker][$visibleMonthLabel] request overlaps visible month, '
          'decision=$markerDecision',
        );
      }
      if (markerDecision != 'show') continue;

      var current = normalizeLeaveDate(request.startDate);
      final end = normalizeLeaveDate(request.endDate);
      while (!current.isAfter(end)) {
        final sameMonth = _isSameMonth(current, _visibleMonth);
        final weekend = _isWeekend(current);
        final holiday = holidays.contains(current);
        final occupied = markers.containsKey(current);
        if (sameMonth && !weekend && !holiday && !occupied) {
          markers[current] = _CalendarMarker(
            type: request.isDispensation
                ? _CalendarMarkerType.dispensation
                : _CalendarMarkerType.leave,
            request: request,
          );
          debugPrint(
            '[CalendarMarker][$visibleMonthLabel] added '
            '${current.toIso8601String()}',
          );
        } else if (sameMonth) {
          debugPrint(
            '[CalendarMarker][$visibleMonthLabel] skipped '
            '${current.toIso8601String()}, '
            'weekend=$weekend, holiday=$holiday, occupied=$occupied',
          );
        }
        current = current.add(const Duration(days: 1));
      }
    }

    return markers;
  }

  String _requestMarkerDecision(LeaveRequestResponse request) {
    final status = request.status.trim().toLowerCase();
    if (_isCanceledStatus(status)) return 'skip:canceled';
    if (_isRejectedStatus(status)) return 'skip:rejected';
    if (request.isDispensation) {
      return _isFinalStatus(status) ? 'show' : 'skip:dispensation-not-final';
    }

    return request.approvalStatus == LeaveApprovalStatus.approved
        ? 'show'
        : 'skip:leave-not-approved-final';
  }

  bool _requestOverlapsMonth(LeaveRequestResponse request, DateTime month) {
    final monthStart = DateTime(month.year, month.month);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    final requestStart = normalizeLeaveDate(request.startDate);
    final requestEnd = normalizeLeaveDate(request.endDate);

    return !requestEnd.isBefore(monthStart) && !requestStart.isAfter(monthEnd);
  }

  void _openMarkerDetail(
    _CalendarMarker? marker, {
    required bool hasSupervisor,
  }) {
    final request = marker?.request;
    if (request == null) return;

    final statusData = request.toStatusData(
      skipsSupervisorApproval: !hasSupervisor,
    );
    if (statusData.status == LeaveApprovalStatus.approved) {
      context.push(RouteName.leaveSuccess, extra: statusData);
    }
  }
}

bool _hasSupervisor(String? supervisorId) {
  final trimmed = supervisorId?.trim();
  return trimmed != null && trimmed.isNotEmpty;
}

class _CalendarMonthHeader extends StatelessWidget {
  const _CalendarMonthHeader({
    required this.month,
    required this.onPreviousTap,
    required this.onNextTap,
  });

  final DateTime month;
  final VoidCallback onPreviousTap;
  final VoidCallback onNextTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPreviousTap,
          icon: const Icon(Icons.chevron_left_rounded),
          color: AppColors.primaryRed,
        ),
        Expanded(
          child: Text(
            _formatMonth(month),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          onPressed: onNextTap,
          icon: const Icon(Icons.chevron_right_rounded),
          color: AppColors.primaryRed,
        ),
      ],
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.visibleMonth,
    required this.markers,
    required this.isLoading,
    required this.onDateTap,
  });

  final DateTime visibleMonth;
  final Map<DateTime, _CalendarMarker> markers;
  final bool isLoading;
  final ValueChanged<_CalendarMarker?> onDateTap;

  @override
  Widget build(BuildContext context) {
    final dates = _calendarDates(visibleMonth);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE7E8EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const _WeekdayHeader(),
          const SizedBox(height: 8),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryRed,
                  strokeWidth: 3,
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dates.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                final date = dates[index];
                final normalizedDate = normalizeLeaveDate(date);
                final marker = markers[normalizedDate];

                return _CalendarDayCell(
                  date: date,
                  isVisibleMonth: date.month == visibleMonth.month,
                  marker: marker,
                  onTap: () => onDateTap(marker),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    const labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Row(
      children: labels
          .map(
            (label) => Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF8A8F98),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.date,
    required this.isVisibleMonth,
    required this.marker,
    required this.onTap,
  });

  final DateTime date;
  final bool isVisibleMonth;
  final _CalendarMarker? marker;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _markerStyle(marker?.type);
    final hasDetail = marker?.request != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasDetail ? onTap : null,
        customBorder: const CircleBorder(),
        child: Center(
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: style.backgroundColor,
              border: style.borderColor == null
                  ? null
                  : Border.all(color: style.borderColor!),
            ),
            child: Text(
              date.day.toString(),
              style: TextStyle(
                color: isVisibleMonth
                    ? style.textColor
                    : const Color(0xFFC4C7CC),
                fontSize: 14,
                fontWeight: marker == null ? FontWeight.w600 : FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 14,
      runSpacing: 10,
      children: [
        _LegendItem(label: 'Weekend', color: Color(0xFFE9ECEF)),
        _LegendItem(label: 'Libur Nasional', color: Color(0xFFFFE1DE)),
        _LegendItem(label: 'Cuti', color: Color(0xFFFFF0C7)),
        _LegendItem(label: 'Dispensasi', color: Color(0xFFDDF4FF)),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF5F6972),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CalendarMarker {
  const _CalendarMarker({required this.type, this.request});

  final _CalendarMarkerType type;
  final LeaveRequestResponse? request;
}

enum _CalendarMarkerType { weekend, holiday, leave, dispensation }

class _CalendarMarkerStyle {
  const _CalendarMarkerStyle({
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
}

_CalendarMarkerStyle _markerStyle(_CalendarMarkerType? type) {
  return switch (type) {
    _CalendarMarkerType.weekend => const _CalendarMarkerStyle(
      backgroundColor: Color(0xFFE9ECEF),
      textColor: Color(0xFF5F6972),
    ),
    _CalendarMarkerType.holiday => const _CalendarMarkerStyle(
      backgroundColor: Color(0xFFFFE1DE),
      textColor: AppColors.primaryRed,
      borderColor: Color(0xFFF4B8B2),
    ),
    _CalendarMarkerType.leave => const _CalendarMarkerStyle(
      backgroundColor: Color(0xFFFFF0C7),
      textColor: Color(0xFF9B6A00),
      borderColor: Color(0xFFFFD36A),
    ),
    _CalendarMarkerType.dispensation => const _CalendarMarkerStyle(
      backgroundColor: Color(0xFFDDF4FF),
      textColor: AppColors.secondaryBlue,
      borderColor: Color(0xFFAADDF1),
    ),
    null => const _CalendarMarkerStyle(
      backgroundColor: Colors.transparent,
      textColor: Colors.black,
    ),
  };
}

List<DateTime> _calendarDates(DateTime month) {
  final firstDay = DateTime(month.year, month.month);
  final firstGridDay = firstDay.subtract(Duration(days: firstDay.weekday - 1));
  return List.generate(42, (index) => firstGridDay.add(Duration(days: index)));
}

List<DateTime> _monthDates(DateTime month) {
  final totalDays = DateTime(month.year, month.month + 1, 0).day;
  return List.generate(
    totalDays,
    (index) => DateTime(month.year, month.month, index + 1),
  );
}

bool _isWeekend(DateTime date) {
  return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
}

bool _isSameMonth(DateTime date, DateTime month) {
  return date.year == month.year && date.month == month.month;
}

bool _isFinalStatus(String status) {
  return status == 'approved' ||
      status == 'disetujui' ||
      status == 'finalized' ||
      status == 'difinalisasi';
}

bool _isRejectedStatus(String status) {
  return status == 'rejected' || status == 'ditolak';
}

bool _isCanceledStatus(String status) {
  return status == 'cancelled' ||
      status == 'canceled' ||
      status == 'dibatalkan';
}

String _formatMonth(DateTime date) {
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
  return '${months[date.month - 1]} ${date.year}';
}
