import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';

const int defaultItemsPerPage = 10;

class AccountService {
  Future<List<AccountsData>> fetchAccounts({
    String sortBy = 'email',
    bool ascending = true,
    int page = 1,
    int limit = defaultItemsPerPage,
    int itemsPerPage = defaultItemsPerPage,
  }) async {
    try {
      final from = (page - 1) * itemsPerPage;
      final to = from + itemsPerPage - 1;

      final query = await supabaseDB
          .from('accounts')
          .select()
          .order(sortBy, ascending: ascending)
          .range(from, to);

      if (query.isEmpty) return [];
      return query.map((item) => AccountsData.fromJson(item)).toList();
    } catch (err) {
      print('Error fetching accounts: \$err \n \$st');
      return [];
    }
  }

  Future<int> getTotalAccountsCount() async {
    try {
      final result = await supabaseDB.from('accounts').select('userID');
      return result.length;
    } catch (err) {
      print('Error fetching account count: \$err \n \$st');
      return 0;
    }
  }
}

// ✅ Riverpod Provider for global use
final accountServiceProvider = Provider<AccountService>((ref) {
  return AccountService();
});
