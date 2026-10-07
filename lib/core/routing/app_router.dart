/// Nexus — GoRouter configuration.
///
/// Uses [StatefulShellRoute.indexedStack] to maintain state across
/// the 5 navigation branches (Dashboard, Inventory, POS, Ledger, Reports).
library;

import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../widgets/adaptive_shell.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/pos/presentation/screens/pos_screen.dart';
import '../../features/ledger/presentation/screens/ledger_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/auth/providers/auth_provider.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
    _ref.listen(isGuestProvider, (_, __) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final isGuest = ref.read(isGuestProvider);
      final isAuthRoute = state.matchedLocation == '/auth';

      if (isGuest) {
        if (isAuthRoute) return '/';
        return null;
      }

      final authState = ref.read(authStateProvider);
      final isAuthenticated = authState.valueOrNull != null;

      if (authState.isLoading) return null;

      if (!isAuthenticated && !isAuthRoute) {
        return '/auth';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AdaptiveShell(navigationShell: navigationShell);
      },
      branches: [
        // ── Branch 0: Dashboard ──────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: DashboardScreen(),
              ),
            ),
          ],
        ),

        // ── Branch 1: Inventory ──────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/inventory',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: InventoryScreen(),
              ),
            ),
          ],
        ),

        // ── Branch 2: POS ────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/pos',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: PosScreen(),
              ),
            ),
          ],
        ),

        // ── Branch 3: Ledger ─────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ledger',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: LedgerScreen(),
              ),
            ),
          ],
        ),

        // ── Branch 4: Reports ────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/reports',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ReportsScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
});
