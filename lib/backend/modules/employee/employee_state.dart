class EmployeeState {
  final List<dynamic> employees;
  final List<Map<String, dynamic>> employeeAccounts;
  final int currentPage;
  final int totalPages;
  final String sortBy;
  final bool ascending;

  EmployeeState({
    required this.employees,
    required this.employeeAccounts,
    required this.currentPage,
    required this.totalPages,
    required this.sortBy,
    required this.ascending,
  });

  factory EmployeeState.initial() {
    return EmployeeState(
      employees: [],
      employeeAccounts: [],
      currentPage: 1,
      totalPages: 1,
      sortBy: 'firstName',
      ascending: true,
    );
  }

  EmployeeState copyWith({
    List<dynamic>? employees,
    List<Map<String, dynamic>>? employeeAccounts,
    int? currentPage,
    int? totalPages,
    String? sortBy,
    bool? ascending,
  }) {
    return EmployeeState(
      employees: employees ?? this.employees,
      employeeAccounts: employeeAccounts ?? this.employeeAccounts,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }
}
