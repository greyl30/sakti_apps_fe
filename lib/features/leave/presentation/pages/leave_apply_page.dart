import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../models/leave_form_data.dart';
import '../widgets/leave_list_item.dart';
import '../widgets/leave_top_bar.dart';

class LeaveApplyPage extends StatefulWidget {
  const LeaveApplyPage({super.key});

  @override
  State<LeaveApplyPage> createState() => _LeaveApplyPageState();
}

class _LeaveApplyPageState extends State<LeaveApplyPage> {
  String _selectedType = 'Cuti Sakit';
  final _reasonController = TextEditingController();
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    // DateRangePicker bawaan Flutter untuk memilih rentang cuti.
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      initialDateRange: _dateRange,
    );

    if (result == null) return;
    setState(() => _dateRange = result);
  }

  void _goToConfirmation() {
    final fallbackStart = DateTime(2026, 7, 13);
    final data = LeaveFormData(
      type: _selectedType,
      reason: _reasonController.text.trim().isEmpty
          ? 'Kepentingan keluarga di Surabaya'
          : _reasonController.text.trim(),
      startDate: _dateRange?.start ?? fallbackStart,
      endDate: _dateRange?.end ?? fallbackStart.add(const Duration(days: 2)),
    );

    context.push(RouteName.leaveConfirmation, extra: data);
  }

  @override
  Widget build(BuildContext context) {
    final startLabel = _dateRange == null ? '' : _formatDate(_dateRange!.start);
    final endLabel = _dateRange == null ? '' : _formatDate(_dateRange!.end);
    final totalDays = _dateRange == null
        ? null
        : _dateRange!.end.difference(_dateRange!.start).inDays + 1;

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top AppBar form ajukan cuti
            const LeaveTopBar(
              title: 'Ajukan cuti',
              subtitle: 'Isi form berikut untuk mengajukan cuti',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                children: [
                  // Card sisa cuti
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD33B32),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: SvgPicture.asset(
                            AppAssets.iconSisa,
                            width: 27,
                            height: 27,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFFD33B32),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sisa Cuti Tahunan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '9 hari tersisa',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  const _FormLabel('Pilih Jenis / Alasan Cuti'),
                  const SizedBox(height: 15),
                  _LeaveTypeTile(
                    title: 'Cuti Sakit',
                    icon: AppAssets.iconSick,
                    isSelected: _selectedType == 'Cuti Sakit',
                    onTap: () => setState(() => _selectedType = 'Cuti Sakit'),
                  ),
                  const SizedBox(height: 17),
                  _LeaveTypeTile(
                    title: 'Izin',
                    icon: AppAssets.iconIzin,
                    isSelected: _selectedType == 'Izin',
                    onTap: () => setState(() => _selectedType = 'Izin'),
                  ),
                  const SizedBox(height: 26),
                  const _FormLabel('Keterangan (opsional)'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _reasonController,
                    minLines: 3,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 12),
                    decoration: _inputDecoration(
                      'Tambahkan keterangan jika diperlukan...',
                    ),
                  ),
                  const SizedBox(height: 26),
                  const _FormLabel('Pilih Rentang Tanggal'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DateBox(
                          label: 'TANGGAL MULAI',
                          value: startLabel,
                          onTap: _pickDateRange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateBox(
                          label: 'TANGGAL SELESAI',
                          value: endLabel,
                          onTap: _pickDateRange,
                        ),
                      ),
                    ],
                  ),
                  if (totalDays != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF8FD),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: const Color(0xFFC6E6F0)),
                      ),
                      child: Text(
                        'Durasi: $totalDays hari kerja\nSisa cuti setelah pengajuan ini: ${13 - totalDays} hari',
                        style: const TextStyle(
                          color: AppColors.secondaryBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Tombol selanjutnya
                  LeavePrimaryButton(
                    label: 'Selanjutnya',
                    onPressed: _goToConfirmation,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFB0B4BC),
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      contentPadding: const EdgeInsets.all(16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE2E4E8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.primaryRed),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _FormLabel extends StatelessWidget {
  const _FormLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        height: 1,
      ),
    );
  }
}

class _LeaveTypeTile extends StatelessWidget {
  const _LeaveTypeTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE7E8EC)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SvgPicture.asset(
                icon,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.primaryRed,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryRed : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryRed
                      : const Color(0xFFC8CDD5),
                  width: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  const _DateBox({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8A8F98),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8FD),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFC6E6F0)),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  AppAssets.iconCalendar,
                  width: 15,
                  height: 15,
                  colorFilter: const ColorFilter.mode(
                    AppColors.secondaryBlue,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF3E6F7B),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
