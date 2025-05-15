import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';

class Header extends StatelessWidget {
  final String title;
  final Widget? leading;
  final VoidCallback? onAvatarTap;

  const Header({
    super.key,
    required this.title,
    this.leading,
    this.onAvatarTap,
  });

  Future<void> _navigateToAccountDetails(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('accounts')
          .select()
          .eq('userID', user.id)
          .maybeSingle();

      if (response != null) {
        final account = AccountsData.fromJson(response);
        context.pushNamed('accountDetails', extra: account);
      }
    } catch (e) {
      debugPrint('Error navigating to account details: $e');
      ToastManager().showToast(context, 'Failed to load account details: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    final user = session?.user;
    final username = user?.email ?? 'Guest';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'NunitoSans',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00AEEF),
                  fontSize: 20,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  username,
                  style: const TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onAvatarTap ?? () => _navigateToAccountDetails(context),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue,
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
