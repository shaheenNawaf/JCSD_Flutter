import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String title;
  final VoidCallback? onAvatarTap;

  const Header({
    super.key,
    required this.title,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'NunitoSans',
              fontWeight: FontWeight.bold,
              color: Color(0xFF00AEEF),
              fontSize: 20,
            ),
          ),
          GestureDetector(
            onTap: onAvatarTap,
            child: const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/avatars/cat2.jpg'),
            ),
          ),
        ],
      ),
    );
  }
}
