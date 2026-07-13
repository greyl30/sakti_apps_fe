import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../leave/presentation/widgets/leave_list_item.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';
import '../models/emergency_dispensation_data.dart';
import '../widgets/emergency_summary_card.dart';

class EmergencyDispensationFormPage extends StatefulWidget {
  const EmergencyDispensationFormPage({super.key});

  @override
  State<EmergencyDispensationFormPage> createState() =>
      _EmergencyDispensationFormPageState();
}

class _EmergencyDispensationFormPageState
    extends State<EmergencyDispensationFormPage> {
  final _reasonController = TextEditingController();
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    // DateRangePicker bawaan Flutter, nanti sumber tanggal tetap bisa diganti backend.
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
    final fallback = dummyEmergencyDispensationData();
    final data = EmergencyDispensationData(
      reason: _reasonController.text.trim().isEmpty
          ? fallback.reason
          : _reasonController.text.trim(),
      startDate: _dateRange?.start ?? fallback.startDate,
      endDate: _dateRange?.end ?? fallback.endDate,
    );

    context.push(RouteName.emergencyDispensationConfirmation, extra: data);
  }

  @override
  Widget build(BuildContext context) {
    final startLabel = _dateRange == null
        ? ''
        : formatEmergencyDate(_dateRange!.start);
    final endLabel = _dateRange == null
        ? ''
        : formatEmergencyDate(_dateRange!.end);

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top AppBar form dispensasi
            const LeaveTopBar(
              title: 'Kirimkan Dispensasi',
              subtitle: 'Isi form berikut untuk mengirimkan dispensasi',
              fallbackRoute: RouteName.emergency,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                children: [
                  const _FormLabel('Isi Alasan'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _reasonController,
                    minLines: 4,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 12),
                    decoration: _inputDecoration('Tambahkan keterangan...'),
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
                  const SizedBox(height: 14),
                  // Info dispensasi tidak mengurangi kuota cuti.
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF8FD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFC6E6F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          AppAssets.iconInfo,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Dispensasi ini tidak akan mengurangi jatah cuti tahunan Anda.',
                            style: TextStyle(
                              color: Color(0xFF5F6972),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Tombol menuju halaman konfirmasi dispensasi.
                  LeavePrimaryButton(
                    label: 'Konfirmasi Dispensasi',
                    onPressed: _goToConfirmation,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 3),
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
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E4E8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryRed),
      ),
    );
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
        fontSize: 13,
        fontWeight: FontWeight.w800,
        height: 1,
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
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8FD),
              borderRadius: BorderRadius.circular(10),
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
