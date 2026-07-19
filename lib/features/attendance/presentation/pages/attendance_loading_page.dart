import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../data/models/attendance_submit_response.dart';
import '../models/attendance_flow_type.dart';
import '../widgets/attendance_flow_app_bar.dart';

class CheckInLoadingPage extends StatefulWidget {
  const CheckInLoadingPage({
    super.key,
    required this.flowType,
    this.isOvertime = false,
    this.response,
  });

  final AttendanceFlowType flowType;
  final bool isOvertime;
  final AttendanceSubmitResponse? response;

  @override
  State<CheckInLoadingPage> createState() => _CheckInLoadingPageState();
}

class _CheckInLoadingPageState extends State<CheckInLoadingPage> {
  @override
  void initState() {
    super.initState();

    // Loading verifikasi sementara sebelum masuk halaman berhasil.
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.go(
        widget.flowType.isCheckIn
            ? RouteName.checkInSuccess
            : RouteName.checkOutSuccess,
        extra: widget.response ?? widget.isOvertime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // AppBar halaman loading
            AttendanceFlowAppBar(
              title: 'Presensi',
              subtitle: widget.flowType.verificationSubtitle,
            ),
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 46,
                      height: 46,
                      child: CircularProgressIndicator(
                        color: AppColors.primaryRed,
                        strokeWidth: 4,
                      ),
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Memverifikasi presensi...',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Mohon tunggu sebentar',
                      style: TextStyle(
                        color: Color(0xFF8A8F98),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }
}
