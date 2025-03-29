import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/audit_logs/audit_services.dart';
import 'package:jcsd_flutter/backend/modules/audit_logs/audit_data.dart';

//Base Provider
final auditLogsProvider = Provider<AuditServices>((ref){
  return AuditServices();
});

//Fetching all Audit
final fetchAuditLog = FutureProvider<List<AuditData>>((ref) async {
  final baseAudit = ref.read(auditLogsProvider);
  
  List<AuditData> auditLogs = await baseAudit.returnInventoryAudit();
  print('In the state management');
  return auditLogs;
});