import 'package:go_router/go_router.dart';

import '../../features/attendance/presentation/pages/attendance_page.dart';
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
      path: RouteName.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: RouteName.attendance,
      builder: (context, state) => const AttendancePage(),
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
