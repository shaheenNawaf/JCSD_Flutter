class PayrollData {
  final int id;
  final DateTime createdAt;
  final int employeeID;
  final double monthlySalary;
  final double calculatedMonthlySalary;
  final double bonus;
  final double deductions;
  final double pagibig;
  final double philhealth;
  final double sss;
  final double withholdingTax;
  final double taxableIncome;

  PayrollData({
    required this.id,
    required this.createdAt,
    required this.employeeID,
    required this.monthlySalary,
    required this.calculatedMonthlySalary,
    required this.bonus,
    required this.deductions,
    required this.pagibig,
    required this.philhealth,
    required this.sss,
    required this.withholdingTax,
    required this.taxableIncome,
  });

  factory PayrollData.fromJson(Map<String, dynamic> json) {
    return PayrollData(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'].toString()), 
      employeeID: json['employeeID'] is int 
        ? json['employeeID'] 
        : int.parse(json['employeeID'].toString()),
      monthlySalary: _toDouble(json['monthlySalary']),
      calculatedMonthlySalary: _toDouble(json['calculatedMonthlySalary']),
      bonus: _toDouble(json['bonus']),
      deductions: _toDouble(json['deductions']),
      pagibig: _toDouble(json['pagibig']),
      philhealth: _toDouble(json['philhealth']),
      sss: _toDouble(json['sss']),
      withholdingTax: _toDouble(json['withholdingTax']),
      taxableIncome: _toDouble(json['taxableIncome']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'employeeID': employeeID,
      'monthlySalary': monthlySalary,
      'calculatedMonthlySalary': calculatedMonthlySalary,
      'bonus': bonus,
      'deductions': deductions,
      'pagibig': pagibig,
      'philhealth': philhealth,
      'sss': sss,
      'withholdingTax': withholdingTax,
      'taxableIncome': taxableIncome,
    };
  }

  static double _toDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.parse(value);
    }
    return 0.0;
  }
}