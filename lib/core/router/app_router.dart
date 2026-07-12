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
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/leave/presentation/pages/leave_page.dart';
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
