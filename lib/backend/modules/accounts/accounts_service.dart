import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';

class AccountService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<AccountsData>> fetchAccounts() async {
    final response = await _supabase
        .from('accounts')
        .select()
        .order('dateCreated', ascending: false);

    return response
        .map<AccountsData>((json) => AccountsData.fromJson(json))
        .toList();
  }
}
