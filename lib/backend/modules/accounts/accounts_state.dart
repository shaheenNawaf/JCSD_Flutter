import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_service.dart';

final accountServiceProvider = Provider((ref) => AccountService());

final fetchAccountList = FutureProvider<List<AccountsData>>((ref) async {
  final accountService = ref.read(accountServiceProvider);
  return await accountService.fetchAccounts();
});
