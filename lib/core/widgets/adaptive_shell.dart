/// Nexus — Adaptive Shell (responsive layout wrapper).
///
/// Uses [LayoutBuilder] at the root to switch between:
/// - Desktop (≥ 900px): Persistent [NavigationRail] on the left
/// - Mobile (< 900px): [BottomNavigationBar] with 5 tabs
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import 'package:nexus/l10n/app_localizations.dart';

class AdaptiveShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AdaptiveShell({super.key, required this.navigationShell});

  static List<_NavItem> _getNavItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      _NavItem(icon: Icons.dashboard_rounded, label: l10n.home),
      _NavItem(icon: Icons.inventory_2_rounded, label: l10n.stock),
      _NavItem(icon: Icons.point_of_sale_rounded, label: l10n.pos),
      _NavItem(icon: Icons.account_balance_rounded, label: l10n.ledger),
      _NavItem(icon: Icons.bar_chart_rounded, label: l10n.stats),
    ];
  }

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= kDesktopBreakpoint;

        if (isDesktop) {
          return _DesktopShell(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            navItems: _getNavItems(context),
            child: navigationShell,
          );
        }

        return _MobileShell(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          navItems: _getNavItems(context),
          child: navigationShell,
        );
      },
    );
  }
}

// ── Desktop Layout ─────────────────────────────────────────────
class _DesktopShell extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<_NavItem> navItems;
  final Widget child;

  const _DesktopShell({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.navItems,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ── Navigation Rail ──────────────────────────────────
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            extended: false,
            minWidth: 72,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.hub_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    kAppName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            destinations: navItems
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.icon),
                    label: Text(item.label),
                  ),
                )
                .toList(),
          ),

          // ── Divider ─────────────────────────────────────────
          const VerticalDivider(thickness: 1, width: 1),

          // ── Content Area ────────────────────────────────────
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ── Mobile Layout ──────────────────────────────────────────────
class _MobileShell extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<_NavItem> navItems;
  final Widget child;

  const _MobileShell({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.navItems,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onDestinationSelected,
        items: navItems
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                activeIcon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Nav Item Data ──────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
