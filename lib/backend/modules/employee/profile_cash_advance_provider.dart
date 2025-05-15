import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final profileCashAdvanceStreamProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) async* {
  final client = Supabase.instance.client;
  final user = client.auth.currentUser;

  if (user == null) {
    yield [];
    return;
  }

  final employee = await client
      .from('employee')
      .select('employeeID')
      .eq('userID', user.id)
      .maybeSingle();

  if (employee == null) {
    yield [];
    return;
  }

  final empID = employee['employeeID'];

  final stream = client
      .from('cash_advance')
      .stream(primaryKey: ['id'])
      .eq('employeeID', empID)
      .order('created_at', ascending: false);

  await for (final data in stream) {
    yield data;
  }
});
