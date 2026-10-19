import 'package:flutter/material.dart';

import '../theme.dart';
import 'bouncy.dart';

/// Round white back button used at the top of each section screen.
class BackBar extends StatelessWidget implements PreferredSizeWidget {
  const BackBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 60,
      backgroundColor: Colors.transparent,
      leadingWidth: 74,
      leading: Center(
        child: Bouncy(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.line),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_rounded,
                size: 22, color: AppColors.ink),
          ),
        ),
      ),
    );
  }
}
