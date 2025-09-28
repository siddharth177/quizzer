import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        "AI Quizzer",
        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
      centerTitle: true,
      backgroundColor: Colors.blue,
      elevation: 2,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
