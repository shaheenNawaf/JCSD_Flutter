class EmployeeData {
  final String employeeID;
  final String userID;
  final bool isAdmin;
  final String companyRole;
  final bool isActive;
  final DateTime createDate;

  EmployeeData(
      {required this.employeeID,
      required this.userID,
      required this.isAdmin,
      required this.companyRole,
      required this.isActive,
      required this.createDate});

  //JSON to Inventory classitem
  factory EmployeeData.fromJson(Map<String, dynamic> json) {
    return EmployeeData(
      employeeID: json['employeeID'] as String,
      userID: json['userID'] as String,
      isAdmin: json['isAdmin'] as bool,
      companyRole: json['companyRole'] as String,
      isActive: json['isActive'] as bool,
      createDate: json['createDate'] as DateTime,
    );
  }

  //Returning the data to a JSON format
  Map<String, dynamic> toJson() {
    return {
      'employeeID': employeeID,
      'userID': userID,
      'isAdmin': isAdmin,
      'companyRole': companyRole,
      'isActive': isActive,
      'createDate': createDate,
    };
  }
}
