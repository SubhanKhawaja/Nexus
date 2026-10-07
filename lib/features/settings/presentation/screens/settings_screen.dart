/// Settings / ERP Workspace — Main screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nexus/core/theme/app_colors.dart';
import 'package:nexus/core/providers/theme_provider.dart';
import 'package:nexus/core/providers/locale_provider.dart';
import 'package:nexus/core/providers/currency_provider.dart';
import 'package:nexus/features/auth/providers/auth_provider.dart';
import 'package:nexus/l10n/app_localizations.dart';
import 'package:nexus/core/widgets/user_avatar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentThemeMode = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);
    final currentCurrency = ref.watch(currencyProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => context.pop(), // Go back since it's pushed
        ),
        title: Text(l10n.erpWorkspace),
        actions: [
          const Padding(
            padding: EdgeInsetsDirectional.only(end: 16),
            child: UserAvatar(radius: 16),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── User Profile Card ──────────────────────────────────
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.cardBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                        decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary, width: 2),
                        image: DecorationImage(
                          image: NetworkImage(user?.photoURL ?? 'https://ui-avatars.com/api/?name=${user?.displayName ?? 'Guest'}'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.displayName ?? l10n.guestUser,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryFor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? l10n.notLoggedIn,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryFor(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref.read(isGuestProvider.notifier).state = false;
                          ref.read(authControllerProvider).signOut();
                        },
                        icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                        label: Text(l10n.signOut, style: const TextStyle(color: AppColors.error)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.cardBorder),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: theme.colorScheme.surface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Preferences ─────────────────────────────────────────
            Text(
              l10n.preferences,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.textTertiaryFor(context),
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.dark_mode_outlined, color: AppColors.textSecondaryFor(context)),
                    title: Text(l10n.theme),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
                      child: Wrap(
                        spacing: 8,
                        children: ThemeMode.values.map((mode) {
                          final isSelected = currentThemeMode == mode;
                          final label = mode == ThemeMode.light ? l10n.light : mode == ThemeMode.dark ? l10n.dark : l10n.system;
                          return ChoiceChip(
                            label: Text(label),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                ref.read(themeModeProvider.notifier).state = mode;
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.language_rounded, color: AppColors.textSecondaryFor(context)),
                    title: Text(l10n.language),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(currentLocale.languageCode == 'ur' ? 'Urdu' : 'English', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryFor(context))),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryFor(context)),
                      ],
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('Select Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                                ListTile(
                                  title: const Text('English'),
                                  trailing: currentLocale.languageCode == 'en' ? const Icon(Icons.check, color: AppColors.primary) : null,
                                  onTap: () {
                                    ref.read(localeProvider.notifier).state = const Locale('en');
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: const Text('Urdu'),
                                  trailing: currentLocale.languageCode == 'ur' ? const Icon(Icons.check, color: AppColors.primary) : null,
                                  onTap: () {
                                    ref.read(localeProvider.notifier).state = const Locale('ur');
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.attach_money_rounded, color: AppColors.textSecondaryFor(context)),
                    title: Text(l10n.currency),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(currentCurrency, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryFor(context))),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryFor(context)),
                      ],
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('Select Currency', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                                ...['PKR', 'USD', 'EUR', 'GBP'].map((c) => ListTile(
                                      title: Text(c),
                                      trailing: currentCurrency == c ? const Icon(Icons.check, color: AppColors.primary) : null,
                                      onTap: () {
                                        ref.read(currencyProvider.notifier).state = c;
                                        Navigator.pop(context);
                                      },
                                    )),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── About Us ──────────────────────────────────────────────
            Text(
              'ABOUT US',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.textTertiaryFor(context),
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.cardBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subhan Khawaja',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryFor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'subhankhawaja76@gmail.com',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryFor(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Flutter & Web Developer',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This app is developed by Subhan Khawaja. I specialize in building high-quality, responsive applications using Flutter and modern web technologies.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryFor(context),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
