class EmployeeData {
  final String employeeID;
  final String userID;
  final bool isAdmin;
  final String companyRole;
  final bool isActive;
  final DateTime createDate;
  final double monthlySalary;

  EmployeeData({
    required this.employeeID,
    required this.userID,
    required this.isAdmin,
    required this.companyRole,
    required this.isActive,
    required this.createDate,
    required this.monthlySalary
  });

  factory EmployeeData.fromJson(Map<String, dynamic> json) {
    return EmployeeData(
      employeeID: json['employeeID'] as String,
      userID: json['userID'].toString(),
      isAdmin: json['isAdmin'] as bool,
      companyRole: json['companyRole'] as String,
      isActive: json['isActive'] as bool,
      createDate: DateTime.parse(json['createDate']),
      monthlySalary: double.parse(json['monthlySalary'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeID': employeeID,
      'userID': userID,
      'isAdmin': isAdmin,
      'companyRole': companyRole,
      'isActive': isActive,
      'createDate': createDate.toIso8601String(),
      'monthlySalary': monthlySalary,
    };
  }
}
