enum UserRole { employee, manager, hrd }

// TODO(Backend):
// Ambil role user dari Supabase/Auth profile.
const currentRole = UserRole.manager;

class HomeApprovalItem {
  const HomeApprovalItem({
    required this.employeeName,
    required this.requestType,
    required this.dateRange,
  });

  final String employeeName;
  final String requestType;
  final String dateRange;
}

const dummyManagerApprovalItems = [
  HomeApprovalItem(
    employeeName: 'Jasmina Melati',
    requestType: 'Cuti Sakit',
    dateRange: '15 - 17 Juli',
  ),
  HomeApprovalItem(
    employeeName: 'Julian Ramadhan',
    requestType: 'Cuti Darurat',
    dateRange: '20 - 22 Juli',
  ),
];

const dummyHrdFinalizationItems = [
  HomeApprovalItem(
    employeeName: 'Jasmina Melati',
    requestType: 'Cuti Sakit',
    dateRange: '15 - 17 Juli',
  ),
  HomeApprovalItem(
    employeeName: 'Julian Ramadhan',
    requestType: 'Cuti Darurat',
    dateRange: '20 - 22 Juli',
  ),
];
