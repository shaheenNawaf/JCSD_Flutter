import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Creates userrole for RBAC (Role Based Access Control)
final userRoleProvider = FutureProvider<String?>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) {
    return null;
  }
  try {
    final employeeData = await Supabase.instance.client
        .from('employee')
        .select('isAdmin')
        .eq('userID', userId)
        .maybeSingle();

    if (employeeData != null && employeeData['isAdmin'] == true) {
      return 'admin';
    } else if (employeeData != null) {
      return 'employee';
    } else {
      return 'client';
    }
  } catch (e) {
    debugPrint("Error fetching user role: $e");
    return null;
  }
});