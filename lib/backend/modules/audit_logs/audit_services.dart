//Supabase Implementation -- personal comments to lahat, plz don't remove
import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/backend/date_converter.dart';
import 'dart:math';


String generateAuditID(){
  const String chars = 'abcdef0123456789';
  final Random rndm = Random();

  String auditID = '';
  for(int i = 0; i < 12; i++){
    auditID += chars[rndm.nextInt(chars.length)];
  }
  return auditID;
}

Future<void> insertAuditLog(String tableName, int empID, String userAction, String actionType) async {
  try{
      await supabaseDB.from(tableName).insert({
        'audit_UUID': generateAuditID(),
        'updateDate': returnCurrentDateTime(),
        'employeeID': empID,
        'userAction': userAction,
        'actionType': actionType,
      }
    );
    print('Added new audit log for the inventory: $actionType');
  }catch (err){
    print('Error recording changes in the application. $err');
  }
}