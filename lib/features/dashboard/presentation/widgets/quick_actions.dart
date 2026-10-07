/// Dashboard — Quick Actions widget.
///
/// Row of shortcut buttons for common tasks:
/// New Sale, Purchase, Add Item.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nexus/core/theme/app_colors.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _ActionButton(
              icon: Icons.add_shopping_cart_rounded,
              label: 'New Sale',
              color: AppColors.primary,
              onTap: () => context.go('/pos'),
            ),
            const SizedBox(width: 12),
            _ActionButton(
              icon: Icons.local_shipping_rounded,
              label: 'Purchase',
              color: AppColors.accent,
              onTap: () => context.go('/pos'),
            ),
            const SizedBox(width: 12),
            _ActionButton(
              icon: Icons.add_box_rounded,
              label: 'Add Item',
              color: AppColors.success,
              onTap: () => context.go('/inventory'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // In dark mode, use a brighter version of the color for text labels
    final labelColor = isDark ? Color.lerp(color, Colors.white, 0.4)! : color;

    return Expanded(
      child: Material(
        color: color.withAlpha(isDark ? 40 : 20),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: labelColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
