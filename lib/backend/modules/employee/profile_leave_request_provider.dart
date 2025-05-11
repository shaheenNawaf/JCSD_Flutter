import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userLeaveRequestStreamProvider = StreamProvider.family
    .autoDispose<List<Map<String, dynamic>>, String>((ref, userID) async* {
  final client = Supabase.instance.client;

  final stream = client
      .from('leave_requests')
      .stream(primaryKey: ['leaveID'])
      .eq('userID', userID)
      .order('startDate', ascending: false);

  await for (final data in stream) {
    yield data;
  }
});
