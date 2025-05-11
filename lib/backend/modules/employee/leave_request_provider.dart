import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final leaveRequestStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) async* {
  final supabase = Supabase.instance.client;
  final stream = supabase
      .from('leave_requests')
      .stream(primaryKey: ['leaveID']).order('startDate', ascending: false);

  await for (final rows in stream) {
    final enrichedRows = await Future.wait(rows.map((item) async {
      final userId = item['userID'];
      final account = await supabase
          .from('accounts')
          .select('firstName, lastName')
          .eq('userID', userId)
          .maybeSingle();

      return {
        ...item,
        'accounts': account ?? {},
      };
    }));

    yield enrichedRows;
  }
});
