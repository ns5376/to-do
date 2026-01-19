import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'TODO List',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 26,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: const Color(0xFFF8FAFC),
      toolbarHeight: 64,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
