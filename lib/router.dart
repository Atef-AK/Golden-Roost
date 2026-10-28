import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'views/main_shell.dart';
import 'views/dashboard/dashboard_screen.dart';
import 'views/flocks/flocks_screen.dart';
import 'views/flocks/flock_detail_screen.dart';
import 'views/flocks/flock_form_screen.dart';
import 'views/incubator/incubator_screen.dart';
import 'views/incubator/batch_detail_screen.dart';
import 'views/incubator/batch_form_screen.dart';
import 'views/finance/finance_screen.dart';
import 'views/finance/electricity_screen.dart';
import 'views/more/more_menu_screen.dart';
import 'views/eggs/eggs_screen.dart';
import 'views/feed/feed_inventory_screen.dart';
import 'views/tasks/tasks_calendar_screen.dart';
import 'views/reports/reports_screen.dart';
import 'views/settings/settings_screen.dart';
import 'views/splash/splash_screen.dart';
import 'views/onboarding/onboarding_screen.dart';
import 'views/articles/articles_list_screen.dart';
import 'views/products/products_catalogue_screen.dart';
import 'views/admin/admin_dashboard_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const OnboardingScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),

        // Branch 1: Flocks
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/flocks',
              builder: (context, state) => const FlocksScreen(),
            ),
          ],
        ),

        // Branch 2: Incubator
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/incubator',
              builder: (context, state) => const IncubatorScreen(),
            ),
          ],
        ),

        // Branch 3: Finance
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/finance',
              builder: (context, state) => const FinanceScreen(),
            ),
          ],
        ),

        // Branch 4: More
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/more',
              builder: (context, state) => const MoreMenuScreen(),
            ),
          ],
        ),
      ],
    ),

    // Deep routes outside bottom bar shell
    GoRoute(
      path: '/flocks/new',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FlockFormScreen(),
    ),
    GoRoute(
      path: '/flocks/edit/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return FlockFormScreen(flockId: id);
      },
    ),
    GoRoute(
      path: '/flocks/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return FlockDetailScreen(flockId: id);
      },
    ),
    GoRoute(
      path: '/incubator/new',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BatchFormScreen(),
    ),
    GoRoute(
      path: '/incubator/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BatchDetailScreen(batchId: id);
      },
    ),
    GoRoute(
      path: '/finance/electricity',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ElectricityScreen(),
    ),
    GoRoute(
      path: '/eggs',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const EggsScreen(),
    ),
    GoRoute(
      path: '/feed',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FeedInventoryScreen(),
    ),
    GoRoute(
      path: '/tasks',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const TasksCalendarScreen(),
    ),
    GoRoute(
      path: '/reports',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/articles',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ArticlesListScreen(),
    ),
    GoRoute(
      path: '/products',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ProductsCatalogueScreen(),
    ),
    GoRoute(
      path: '/admin',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AdminDashboardScreen(),
    ),
  ],
);
