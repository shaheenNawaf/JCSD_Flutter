import 'package:flutter/material.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;
const String expectedCheckInTime = '08:00:00';
const int expectedWorkDurationMinutes = 8 * 60;

Future<void> checkIn(BuildContext context) async {
  final User? user = supabase.auth.currentUser;
  if (user != null) {
    try {
      await supabase.from('attendance').insert({
        'userID': user.id,
        'check_in_time': DateTime.now().toIso8601String(),
        'attendance_date': DateTime.now().toLocal().toString().split(' ')[0],
      });
      ToastManager().showToast(context, 'Check-in successful', Colors.green);
    } catch (error) {
      print('Error during check-in: $error');
      if (error is PostgrestException && error.code == '23505') {
        ToastManager().showToast(context, 'You have already checked-in today.', Colors.red);
      } else {
      }
    }
  }
}

Future<void> checkOut(BuildContext context) async {
  final User? user = supabase.auth.currentUser;
  if (user != null) {
    try {
      final now = DateTime.now().toIso8601String();
      final today = DateTime.now().toLocal().toString().split(' ')[0];

      final List<Map<String, dynamic>> existingAttendance = await supabase
          .from('attendance')
          .select('id, check_in_time')
          .eq('userID', user.id)
          .eq('attendance_date', today)
          .not('check_in_time', 'is', null)
          .filter('check_out_time', 'is', null) 
          .limit(1);
      if (existingAttendance.isNotEmpty) {
        final attendanceId = existingAttendance.first['id'];
        final checkInTime = DateTime.parse(existingAttendance.first['check_in_time']).toLocal();
        final workDuration = DateTime.parse(now).difference(checkInTime).inMinutes;
        final expectedCheckIn = DateTime.parse('$today $expectedCheckInTime').toLocal();
        int lateMinutes = 0;
        if (checkInTime.isAfter(expectedCheckIn)) {
          lateMinutes = checkInTime.difference(expectedCheckIn).inMinutes;
        }

        int overtimeMinutes = 0;
        if (workDuration > expectedWorkDurationMinutes) {
          overtimeMinutes = workDuration - expectedWorkDurationMinutes;
        }



        await supabase.from('attendance').update({
          'check_out_time': now,
          'late_minutes': lateMinutes,
          'overtime_minutes': overtimeMinutes,
        }).eq('id', attendanceId);
        ToastManager().showToast(context, 'Check-out successful', Colors.green);
      } else {
        ToastManager().showToast(context, 'No active check-in found for today.', Colors.red);
      }
    } catch (error) {
      print('Error during check-out: $error');
    }
  }
}

Future<List<Map<String, dynamic>>> fetchUserAttendance(DateTime startDate, DateTime endDate,String userId) async {
  try {
    final List<Map<String, dynamic>> data = await supabase
        .from('attendance')
        .select('*')
        .eq('userID', userId)
        .gte('attendance_date', startDate.toLocal().toString().split(' ')[0])
        .lte('attendance_date', endDate.toLocal().toString().split(' ')[0]);
    return data;
  } catch (error) {
    print('Error fetching attendance: $error');
    return [];
  }
}

// Future<List<Map<String, dynamic>>> fetchAttendanceByDate({
//   required DateTime date,
//   String? userId, // Optional userId for admin to fetch specific user's attendance
// }) async {
//   try {
//     final PostgrestFilterBuilder<List<Map<String, dynamic>>> query =
//         supabase.from('attendance').select('*, profiles(full_name)').eq(
//               'attendance_date',
//               date.toLocal().toString().split(' ')[0],
//             );

//     if (userId != null) {
//       query.eq('userID', userId);
//     }

//     final List<Map<String, dynamic>> data = await query;
//     return data;
//   } catch (error) {
//     print('Error fetching attendance by date: $error');
//     return [];
//   }
// }