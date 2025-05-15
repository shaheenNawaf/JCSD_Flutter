import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final cashAdvanceStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) async* {
  final supabase = Supabase.instance.client;

  final stream = supabase
      .from('cash_advance')
      .stream(primaryKey: ['id']).order('created_at', ascending: false);

  await for (final rows in stream) {
    final enriched = await Future.wait(rows.map((item) async {
      final emp = await supabase
          .from('employee')
          .select('userID')
          .eq('employeeID', item['employeeID'])
          .maybeSingle();

      final acc = emp != null
          ? await supabase
              .from('accounts')
              .select('firstName, lastName')
              .eq('userID', emp['userID'])
              .maybeSingle()
          : null;

      return {
        ...item,
        'name':
            acc != null ? "${acc['firstName']} ${acc['lastName']}" : 'Unknown',
        'monthlySalary': '₱${item['monthlySalary'].toString()}',
        'cashAdvance': '₱${item['cashAdvance'].toString()}',
        'reason': item['reason'],
        'status': item['status'],
      };
    }));
    yield enriched;
  }
});
