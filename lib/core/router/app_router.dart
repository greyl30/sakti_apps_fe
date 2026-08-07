import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../deep_link/reset_password_deep_link_parser.dart';
import '../supabase/supabase_client.dart';
import '../../features/attendance/data/models/attendance_submit_response.dart';
import '../../features/attendance/presentation/models/attendance_flow_type.dart';
import '../../features/attendance/presentation/pages/attendance_loading_page.dart';
import '../../features/attendance/presentation/pages/attendance_success_page.dart';
import '../../features/attendance/presentation/pages/attendance_verification_page.dart';
import '../../features/attendance/presentation/pages/attendance_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/leave/presentation/models/leave_form_data.dart';
import '../../features/leave/presentation/models/leave_request_status.dart';
import '../../features/leave/presentation/pages/leave_apply_page.dart';
import '../../features/leave/presentation/pages/leave_cancel_page.dart';
import '../../features/leave/presentation/pages/leave_cancel_success_page.dart';
import '../../features/leave/presentation/pages/leave_confirmation_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/models/hrd_leave_finalization.dart';
import '../../features/home/presentation/models/manager_leave_approval.dart';
import '../../features/home/presentation/pages/hrd_leave_finalization_detail_page.dart';
import '../../features/home/presentation/pages/hrd_leave_finalization_list_page.dart';
import '../../features/home/presentation/pages/manager_leave_approval_detail_page.dart';
import '../../features/home/presentation/pages/manager_leave_approval_list_page.dart';
import '../../features/home/presentation/pages/manager_leave_reject_reason_page.dart';
import '../../features/leave/presentation/pages/leave_history_page.dart';
import '../../features/leave/presentation/pages/leave_page.dart';
import '../../features/leave/presentation/pages/leave_status_page.dart';
import '../../features/leave/presentation/pages/leave_success_page.dart';
import '../../features/notification/presentation/models/notification_model.dart';
import '../../features/notification/presentation/pages/notification_detail_page.dart';
import '../../features/notification/presentation/pages/notification_page.dart';
import '../../features/profile/presentation/pages/change_password_placeholder_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/telegram_connect_page.dart';
import '../../features/profile/presentation/pages/telegram_success_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/splash/presentation/pages/welcome_page.dart';
import 'route_name.dart';

const _publicRoutes = {
  RouteName.welcome,
  RouteName.splash,
  RouteName.login,
  RouteName.forgotPassword,
  RouteName.resetPassword,
};

const _authEntryRoutes = {RouteName.login};

const _roleProtectedRoutes = <String, Set<String>>{
  RouteName.managerLeaveApprovals: {'atasan'},
  RouteName.managerLeaveApprovalDetail: {'atasan'},
  RouteName.managerLeaveRejectReason: {'atasan'},
  RouteName.hrdLeaveFinalizations: {'hrd'},
  RouteName.hrdLeaveFinalizationDetail: {'hrd'},
  RouteName.telegramConnect: {'atasan', 'manager'},
  RouteName.telegramSuccess: {'atasan', 'manager'},
};

final appRouter = GoRouter(
  initialLocation: RouteName.welcome,
  redirect: (context, state) {
    final location = state.uri.path;
    final resetPasswordLocation = _resetPasswordLocationFromDeepLink(state.uri);
    if (resetPasswordLocation != null) {
      return resetPasswordLocation;
    }

    final hasSession = AppSupabaseClient.client.auth.currentSession != null;
    final authState = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(authProvider);
    final userRole = _normalizeRole(authState.user?.peran);
    final isPublicRoute = _publicRoutes.contains(location);
    final isAuthEntryRoute = _authEntryRoutes.contains(location);
    final allowedRoles = _allowedRolesFor(location);

    if (!hasSession && !isPublicRoute) {
      return RouteName.login;
    }

    if (hasSession &&
        authState.user == null &&
        location != RouteName.splash &&
        !isPublicRoute) {
      return RouteName.welcome;
    }

    if (hasSession && isAuthEntryRoute) {
      return RouteName.home;
    }

    if (allowedRoles != null && !allowedRoles.contains(userRole)) {
      return RouteName.home;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: RouteName.welcome,
      builder: (context, state) => const WelcomePage(),
    ),
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
      path: RouteName.resetPassword,
      builder: (context, state) =>
          ResetPasswordPage(token: extractResetPasswordToken(state.uri)),
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
      builder: (context, state) => CheckInLoadingPage(
        flowType: AttendanceFlowType.checkIn,
        response: state.extra is AttendanceSubmitResponse
            ? state.extra! as AttendanceSubmitResponse
            : null,
        isOvertime: state.extra == true,
      ),
    ),
    GoRoute(
      path: RouteName.checkInSuccess,
      builder: (context, state) => CheckInSuccessPage(
        flowType: AttendanceFlowType.checkIn,
        response: state.extra is AttendanceSubmitResponse
            ? state.extra! as AttendanceSubmitResponse
            : null,
        isOvertime: state.extra == true,
      ),
    ),
    GoRoute(
      path: RouteName.checkOutVerification,
      builder: (context, state) =>
          const CheckInVerificationPage(flowType: AttendanceFlowType.checkOut),
    ),
    GoRoute(
      path: RouteName.checkOutLoading,
      builder: (context, state) => CheckInLoadingPage(
        flowType: AttendanceFlowType.checkOut,
        response: state.extra is AttendanceSubmitResponse
            ? state.extra! as AttendanceSubmitResponse
            : null,
        isOvertime: state.extra == true,
      ),
    ),
    GoRoute(
      path: RouteName.checkOutSuccess,
      builder: (context, state) => CheckInSuccessPage(
        flowType: AttendanceFlowType.checkOut,
        response: state.extra is AttendanceSubmitResponse
            ? state.extra! as AttendanceSubmitResponse
            : null,
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
                reason: '',
                startDate: DateTime(2026, 7, 13),
                endDate: DateTime(2026, 7, 15),
              ),
      ),
    ),
    GoRoute(
      path: RouteName.leaveStatus,
      builder: (context, state) {
        final extra = state.extra;
        final routeData = extra is LeaveStatusRouteData
            ? extra
            : LeaveStatusRouteData(
                data: extra is LeaveRequestStatusData
                    ? extra
                    : dummyLeaveWaitingSupervisor,
              );

        return LeaveStatusPage(
          data: routeData.data,
          fallbackRoute: routeData.fallbackRoute,
          bottomNavigationIndex: routeData.bottomNavigationIndex,
        );
      },
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
            ? extra['reason'] as String? ?? ''
            : '';

        return LeaveCancelSuccessPage(data: data, cancelReason: reason);
      },
    ),
    GoRoute(
      path: RouteName.leaveHistory,
      builder: (context, state) => const LeaveHistoryPage(),
    ),
    GoRoute(
      path: RouteName.notification,
      builder: (context, state) => const NotificationPage(),
    ),
    GoRoute(
      path: RouteName.notificationDetail,
      builder: (context, state) => NotificationDetailPage(
        notification: state.extra is NotificationModel
            ? state.extra! as NotificationModel
            : dummyEmployeeNotifications.first,
      ),
    ),
    GoRoute(
      path: RouteName.profile,
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: RouteName.changePassword,
      builder: (context, state) => const ChangePasswordPlaceholderPage(),
    ),
    GoRoute(
      path: RouteName.telegramConnect,
      builder: (context, state) => const TelegramConnectPage(),
    ),
    GoRoute(
      path: RouteName.telegramSuccess,
      builder: (context, state) => const TelegramSuccessPage(),
    ),
    GoRoute(
      path: RouteName.history,
      builder: (context, state) => const HistoryPage(),
    ),
    GoRoute(
      path: RouteName.managerLeaveApprovals,
      builder: (context, state) => const ManagerLeaveApprovalListPage(),
    ),
    GoRoute(
      path: RouteName.managerLeaveApprovalDetail,
      builder: (context, state) => ManagerLeaveApprovalDetailPage(
        approval: state.extra is ManagerLeaveApproval
            ? state.extra! as ManagerLeaveApproval
            : managerApprovalStore.value.isNotEmpty
            ? managerApprovalStore.value.first
            : fallbackManagerApproval,
      ),
    ),
    GoRoute(
      path: RouteName.managerLeaveRejectReason,
      builder: (context, state) => ManagerLeaveRejectReasonPage(
        approval: state.extra is ManagerLeaveApproval
            ? state.extra! as ManagerLeaveApproval
            : managerApprovalStore.value.isNotEmpty
            ? managerApprovalStore.value.first
            : fallbackManagerApproval,
      ),
    ),
    GoRoute(
      path: RouteName.hrdLeaveFinalizations,
      builder: (context, state) => const HrdLeaveFinalizationListPage(),
    ),
    GoRoute(
      path: RouteName.hrdLeaveFinalizationDetail,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is HrdLeaveFinalization) {
          return HrdLeaveFinalizationDetailPage(finalization: extra);
        }

        return const HrdLeaveFinalizationListPage();
      },
    ),
  ],
);

Set<String>? _allowedRolesFor(String location) {
  for (final entry in _roleProtectedRoutes.entries) {
    if (location == entry.key || location.startsWith('${entry.key}/')) {
      return entry.value;
    }
  }

  return null;
}

String _normalizeRole(String? role) => role?.trim().toLowerCase() ?? '';

String? _resetPasswordLocationFromDeepLink(Uri uri) {
  if (!isResetPasswordDeepLink(uri)) return null;

  logResetPasswordDeepLink('GoRouter', uri);
  return resetPasswordLocationFromUri(uri);
}
