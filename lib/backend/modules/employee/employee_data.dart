class EmployeeData {
  final String employeeID;
  final String userID;
  final bool isAdmin;
  final String companyRole;
  final String position;
  final bool isActive;
  final DateTime createDate;
  final double monthlySalary;

  EmployeeData(
      {required this.employeeID,
      required this.userID,
      required this.isAdmin,
      required this.companyRole,
      required this.position,
      required this.isActive,
      required this.createDate,
      required this.monthlySalary});

  factory EmployeeData.fromJson(Map<String, dynamic> json) {
    return EmployeeData(
      employeeID: json['employeeID'].toString(), // convert int to string
      userID: json['userID'].toString(),
      isAdmin: json['isAdmin'] as bool,
      companyRole: json['companyRole'] as String,
      position: json['position'] as String,
      isActive: json['isActive'] as bool,
      createDate: DateTime.parse(json['createDate']),
      monthlySalary: double.tryParse(json['monthlySalary'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeID': employeeID,
      'userID': userID,
      'isAdmin': isAdmin,
      'companyRole': companyRole,
      'position': position,
      'isActive': isActive,
      'createDate': createDate.toIso8601String(),
      'monthlySalary': monthlySalary,
    };
  }
}
