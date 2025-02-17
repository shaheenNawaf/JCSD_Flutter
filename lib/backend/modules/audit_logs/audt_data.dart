//Standard Backend Imports for Audit Logs
import 'package:jcsd_flutter/backend/date_converter.dart';
import 'package:jcsd_flutter/backend/modules/audit_logs/audit_services.dart';

class AuditData {
  final int auditID;
  final String auditUUID;
  final String actionType;
  final int employeeID;
  final String userAction;

  AuditData({
    required this.auditID,
    required this.auditUUID,
    required this.actionType,
    required this.employeeID,
    required this.userAction,
  });

  //Grabber from JSON return from Supabase
  factory AuditData.fromJson(Map<String, dynamic> json) {
    return AuditData(
      auditID: json['auditMain'],
      auditUUID: json['audit_UUID'],
      actionType: json['actionType'],
      employeeID: json['employeeID'],
      userAction: json['userAction'],
    );
  }
}
