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
    print('Found ${data.length} records');
    print(userId);
    return data;
  } catch (error) {
    print('Error fetching attendance: $error');
    return [];
  }
}

Future<bool> updateAttendanceRecord({
  required String attendanceId,
  String? newCheckInTime,
  String? newCheckOutTime,

  required BuildContext context,
}) async {
  try {
    final Map<String, dynamic> updates = {};

    final existingRecord = await supabase
        .from('attendance')
        .select()
        .eq('id', attendanceId)
        .single();
    
    if (newCheckInTime != null && newCheckInTime.isNotEmpty) {
      final String checkInTimeStr = newCheckInTime.toString();
      final existingDate = existingRecord['attendance_date'].toString().split(' ')[0];
      updates['check_in_time'] = '$existingDate $checkInTimeStr';
    }
    
    if (newCheckOutTime != null) {
      final String checkOutTimeStr = newCheckOutTime.toString();
      final existingDate = existingRecord['attendance_date'].toString().split(' ')[0];
      updates['check_out_time'] = '$existingDate $checkOutTimeStr';
    }

    if (updates.isNotEmpty) {
      final response = await supabase.from('attendance').update(updates).eq('id', attendanceId).select();
      if (response.isNotEmpty) {
        ToastManager().showToast(context, 'Attendance record updated successfully', Colors.green);
        return true;
      } else {
        print('Error updating attendance: No data returned');
        ToastManager().showToast(context, 'Failed to update attendance record', Colors.red);
      }
    } else {
      ToastManager().showToast(context, 'No changes to update', Colors.orange);
    }
    return false;
  } catch (error) {
    print('Unexpected error updating attendance: $error');
    ToastManager().showToast(context, 'An unexpected error occurred', Colors.red);
    return false;
  }
}

Future<String> calculateTotalHoursWorked(String userId, DateTime startDate, DateTime endDate) async {
  try {
    final attendanceRecords = await fetchUserAttendance(startDate, endDate, userId);
    
    Duration totalDuration = Duration.zero;
    
    for (var record in attendanceRecords) {
      if (record['check_in_time'] != null && record['check_out_time'] != null) {
        final checkIn = DateTime.parse(record['check_in_time']);
        final checkOut = DateTime.parse(record['check_out_time']);
        totalDuration += checkOut.difference(checkIn);
      }
    }
    
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes.remainder(60);
    
    return '$hours hours ${minutes}mins';
  } catch (e) {
    debugPrint('Error calculating total hours: $e');
    return 'N/A';
  }
}