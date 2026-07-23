enum UserRole { employee, manager, hrd }

// TODO(Backend):
// Role nantinya selalu berasal dari AuthState.user yang diisi data Supabase.
UserRole userRoleFromPeran(String? peran) {
  switch (peran?.trim().toLowerCase()) {
    case 'atasan':
      return UserRole.manager;
    case 'hrd':
      return UserRole.hrd;
    case 'karyawan':
    default:
      return UserRole.employee;
  }
}

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
