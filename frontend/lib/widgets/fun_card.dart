import 'package:flutter/material.dart';

import '../theme.dart';
import 'bouncy.dart';

/// Chunky, colourful tile used for lessons, quiz levels and games.
class FunCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String meta;
  final Color color;
  final bool locked;
  final VoidCallback? onTap;

  const FunCard({
    super.key,
    required this.icon,
    required this.title,
    required this.meta,
    required this.color,
    this.locked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Bouncy(
      onTap: locked ? null : onTap,
      child: Opacity(
        opacity: locked ? 0.55 : 1,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.line),
            boxShadow: glow(color, opacity: 0.18, blur: 18),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: icon,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        meta,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                locked ? Icons.lock_rounded : Icons.chevron_right_rounded,
                color: locked ? AppColors.inkSoft : color,
                size: locked ? 20 : 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
