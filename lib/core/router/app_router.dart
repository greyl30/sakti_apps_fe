import 'package:go_router/go_router.dart';

import '../../features/attendance/presentation/models/attendance_flow_type.dart';
import '../../features/attendance/presentation/pages/check_in_confirmation_page.dart';
import '../../features/attendance/presentation/pages/check_in_loading_page.dart';
import '../../features/attendance/presentation/pages/check_in_success_page.dart';
import '../../features/attendance/presentation/pages/check_in_verification_page.dart';
import '../../features/attendance/presentation/pages/attendance_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/darurat/presentation/pages/emergency_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/leave/presentation/models/leave_form_data.dart';
import '../../features/leave/presentation/models/leave_request_status.dart';
import '../../features/leave/presentation/pages/leave_apply_page.dart';
import '../../features/leave/presentation/pages/leave_cancel_page.dart';
import '../../features/leave/presentation/pages/leave_cancel_success_page.dart';
import '../../features/leave/presentation/pages/leave_confirmation_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/leave/presentation/pages/leave_page.dart';
import '../../features/leave/presentation/pages/leave_status_page.dart';
import '../../features/leave/presentation/pages/leave_success_page.dart';
import '../../features/notification/presentation/pages/notification_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import 'route_name.dart';

final appRouter = GoRouter(
  initialLocation: RouteName.home,
  routes: [
    GoRoute(
      path: RouteName.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: RouteName.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RouteName.forgotPassword,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: RouteName.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: RouteName.attendance,
      builder: (context, state) => const AttendancePage(),
    ),
    GoRoute(
      path: RouteName.checkInVerification,
      builder: (context, state) =>
          const CheckInVerificationPage(flowType: AttendanceFlowType.checkIn),
    ),
    GoRoute(
      path: RouteName.checkInLoading,
      builder: (context, state) =>
          const CheckInLoadingPage(flowType: AttendanceFlowType.checkIn),
    ),
    GoRoute(
      path: RouteName.checkInConfirmation,
      builder: (context, state) =>
          const CheckInConfirmationPage(flowType: AttendanceFlowType.checkIn),
    ),
    GoRoute(
      path: RouteName.checkInSuccess,
      builder: (context, state) =>
          const CheckInSuccessPage(flowType: AttendanceFlowType.checkIn),
    ),
    GoRoute(
      path: RouteName.checkOutVerification,
      builder: (context, state) =>
          const CheckInVerificationPage(flowType: AttendanceFlowType.checkOut),
    ),
    GoRoute(
      path: RouteName.checkOutLoading,
      builder: (context, state) =>
          const CheckInLoadingPage(flowType: AttendanceFlowType.checkOut),
    ),
    GoRoute(
      path: RouteName.checkOutConfirmation,
      builder: (context, state) =>
          const CheckInConfirmationPage(flowType: AttendanceFlowType.checkOut),
    ),
    GoRoute(
      path: RouteName.checkOutSuccess,
      builder: (context, state) => CheckInSuccessPage(
        flowType: AttendanceFlowType.checkOut,
        isOvertime: state.extra == true,
      ),
    ),
    GoRoute(
      path: RouteName.leave,
      builder: (context, state) => const LeavePage(),
    ),
    GoRoute(
      path: RouteName.leaveApply,
      builder: (context, state) => const LeaveApplyPage(),
    ),
    GoRoute(
      path: RouteName.leaveConfirmation,
      builder: (context, state) => LeaveConfirmationPage(
        data: state.extra is LeaveFormData
            ? state.extra! as LeaveFormData
            : LeaveFormData(
                type: 'Izin',
                reason: 'Kepentingan keluarga di Surabaya',
                startDate: DateTime(2026, 7, 13),
                endDate: DateTime(2026, 7, 15),
              ),
      ),
    ),
    GoRoute(
      path: RouteName.leaveStatus,
      builder: (context, state) => LeaveStatusPage(
        data: state.extra is LeaveRequestStatusData
            ? state.extra! as LeaveRequestStatusData
            : dummyLeaveWaitingSupervisor,
      ),
    ),
    GoRoute(
      path: RouteName.leaveSuccess,
      builder: (context, state) => LeaveSuccessPage(
        data: state.extra is LeaveRequestStatusData
            ? state.extra! as LeaveRequestStatusData
            : dummyLeaveApproved,
      ),
    ),
    GoRoute(
      path: RouteName.leaveCancel,
      builder: (context, state) => LeaveCancelPage(
        data: state.extra is LeaveRequestStatusData
            ? state.extra! as LeaveRequestStatusData
            : dummyLeaveApproved,
      ),
    ),
    GoRoute(
      path: RouteName.leaveCancelSuccess,
      builder: (context, state) {
        final extra = state.extra;
        final data = extra is Map<String, Object?>
            ? extra['data'] as LeaveRequestStatusData? ?? dummyLeaveApproved
            : dummyLeaveApproved;
        final reason = extra is Map<String, Object?>
            ? extra['reason'] as String? ?? 'Ada keperluan mendadak lainnya'
            : 'Ada keperluan mendadak lainnya';

        return LeaveCancelSuccessPage(data: data, cancelReason: reason);
      },
    ),
    GoRoute(
      path: RouteName.emergency,
      builder: (context, state) => const EmergencyPage(),
    ),
    GoRoute(
      path: RouteName.notification,
      builder: (context, state) => const NotificationPage(),
    ),
    GoRoute(
      path: RouteName.profile,
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: RouteName.history,
      builder: (context, state) => const HistoryPage(),
    ),
  ],
);
