import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final profileCashAdvanceProvider = StreamProvider.family
    .autoDispose<List<Map<String, dynamic>>, int?>((ref, employeeID) async* {
  final client = Supabase.instance.client;

  int? targetEmpID = employeeID;

  if (targetEmpID == null) {
    final user = client.auth.currentUser;
    if (user == null) {
      yield [];
      return;
    }

    final emp = await client
        .from('employee')
        .select('employeeID')
        .eq('userID', user.id)
        .maybeSingle();

    if (emp == null) {
      yield [];
      return;
    }

    targetEmpID = emp['employeeID'];
  }

  final stream = client
      .from('cash_advance')
      .stream(primaryKey: ['id'])
      .eq('employeeID', targetEmpID!)
      .order('created_at', ascending: false);

  await for (final data in stream) {
    yield data;
  }
});
