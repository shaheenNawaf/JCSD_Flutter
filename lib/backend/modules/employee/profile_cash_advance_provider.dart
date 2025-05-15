import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final profileCashAdvanceProvider = StreamProvider.family
    .autoDispose<List<Map<String, dynamic>>, int>((ref, employeeID) async* {
  final client = Supabase.instance.client;

  final stream = client
      .from('cash_advance')
      .stream(primaryKey: ['id'])
      .eq('employeeID', employeeID)
      .order('created_at', ascending: false);

  await for (final rows in stream) {
    yield List<Map<String, dynamic>>.from(rows);
  }
});
