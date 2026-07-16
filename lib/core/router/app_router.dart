import 'package:go_router/go_router.dart';

import '../../features/attendance/presentation/models/attendance_flow_type.dart';
import '../../features/attendance/presentation/pages/attendance_confirmation_page.dart';
import '../../features/attendance/presentation/pages/attendance_loading_page.dart';
import '../../features/attendance/presentation/pages/attendance_success_page.dart';
import '../../features/attendance/presentation/pages/attendance_verification_page.dart';
import '../../features/attendance/presentation/pages/attendance_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/darurat/presentation/models/emergency_dispensation_data.dart';
import '../../features/darurat/presentation/models/emergency_leave_data.dart';
import '../../features/darurat/presentation/pages/emergency_dispensation_confirmation_page.dart';
import '../../features/darurat/presentation/pages/emergency_dispensation_form_page.dart';
import '../../features/darurat/presentation/pages/emergency_dispensation_success_page.dart';
import '../../features/darurat/presentation/pages/emergency_history_page.dart';
import '../../features/darurat/presentation/pages/emergency_leave_confirmation_page.dart';
import '../../features/darurat/presentation/pages/emergency_leave_form_page.dart';
import '../../features/darurat/presentation/pages/emergency_page.dart';
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
import '../../features/splash/presentation/pages/splash_page.dart';
import 'route_name.dart';

final appRouter = GoRouter(
  initialLocation: RouteName.splash,
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
            ? extra['reason'] as String? ?? 'Ada keperluan mendadak lainnya'
            : 'Ada keperluan mendadak lainnya';

        return LeaveCancelSuccessPage(data: data, cancelReason: reason);
      },
    ),
    GoRoute(
      path: RouteName.leaveHistory,
      builder: (context, state) => const LeaveHistoryPage(),
    ),
    GoRoute(
      path: RouteName.emergency,
      builder: (context, state) => const EmergencyPage(),
    ),
    GoRoute(
      path: RouteName.emergencyDispensation,
      builder: (context, state) => const EmergencyDispensationFormPage(),
    ),
    GoRoute(
      path: RouteName.emergencyDispensationConfirmation,
      builder: (context, state) => EmergencyDispensationConfirmationPage(
        data: state.extra is EmergencyDispensationData
            ? state.extra! as EmergencyDispensationData
            : dummyEmergencyDispensationData(),
      ),
    ),
    GoRoute(
      path: RouteName.emergencyDispensationSuccess,
      builder: (context, state) => EmergencyDispensationSuccessPage(
        data: state.extra is EmergencyDispensationData
            ? state.extra! as EmergencyDispensationData
            : dummyEmergencyDispensationData(),
      ),
    ),
    GoRoute(
      path: RouteName.emergencyLeave,
      builder: (context, state) => const EmergencyLeaveFormPage(),
    ),
    GoRoute(
      path: RouteName.emergencyLeaveConfirmation,
      builder: (context, state) => EmergencyLeaveConfirmationPage(
        data: state.extra is EmergencyLeaveData
            ? state.extra! as EmergencyLeaveData
            : dummyEmergencyLeaveData(),
      ),
    ),
    GoRoute(
      path: RouteName.emergencyHistory,
      builder: (context, state) => const EmergencyHistoryPage(),
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
      builder: (context, state) => HrdLeaveFinalizationDetailPage(
        finalization: state.extra is HrdLeaveFinalization
            ? state.extra! as HrdLeaveFinalization
            : hrdFinalizationStore.value.isNotEmpty
            ? hrdFinalizationStore.value.first
            : fallbackHrdFinalization,
      ),
    ),
  ],
);
