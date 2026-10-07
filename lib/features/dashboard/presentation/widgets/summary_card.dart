/// Dashboard — Summary Card widget.
///
/// Reusable card displaying a title, large value, and optional
/// subtitle/badge (e.g. percentage change).
library;

import 'package:flutter/material.dart';

import 'package:nexus/core/theme/app_colors.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? badgeColor;
  final String? badge;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.badgeColor,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryFor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (icon != null)
                    Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
                ],
              ),
              const SizedBox(height: 8),

              // ── Value ────────────────────────────────────────
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryFor(context),
                ),
              ),

              // ── Badge / Subtitle ────────────────────────────
              if (badge != null || subtitle != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (badgeColor ?? AppColors.success).withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: badgeColor ?? AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (badge != null && subtitle != null)
                      const SizedBox(width: 8),
                    if (subtitle != null)
                      Expanded(
                        child: Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiaryFor(context),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
