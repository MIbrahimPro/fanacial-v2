import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/loans_provider.dart';
import 'providers/monthly_tracker_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/theme_provider.dart';
import 'services/hive_initializer.dart';
import 'services/storage_service.dart';
import 'utils/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/loans_manager/pages/person_detail_page.dart';
import 'screens/monthly_tracker/pages/transaction_detail_page.dart';
import 'screens/monthly_tracker_screen.dart';
import 'screens/stats_manager_screen.dart';
import 'screens/loans_manager_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveInitializer.instance.init();

  final settings = StorageService.instance.getSettings();
  final initialTheme =
      settings.theme == 'dark' ? ThemeMode.dark : ThemeMode.light;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..setThemeMode(initialTheme),
        ),
        ChangeNotifierProvider(create: (_) => MonthlyTrackerProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
        ChangeNotifierProvider(create: (_) => LoansProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        Provider.value(value: StorageService.instance),
      ],
      child: const MoneyManagerApp(),
    ),
  );
}

class MoneyManagerApp extends StatelessWidget {
  const MoneyManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;

    return MaterialApp(
      title: 'Money Manager',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const MainShell(),
      routes: {
        '/transaction-detail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return TransactionDetailPage(transactionId: args);
        },
        '/person-detail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return PersonDetailPage(personId: args);
        },
      },
    );
  }
}

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _screens = [
    DashboardScreen(),
    MonthlyTrackerScreen(),
    StatsManagerScreen(),
    LoansManagerScreen(),
    SettingsScreen(),
  ];

  static const _titles = [
    'Dashboard',
    'Monthly Tracker',
    'Stats',
    'Loans',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<NavigationProvider>().currentIndex;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        return Scaffold(
          appBar: AppBar(title: Text(_titles[currentIndex])),
          body: Row(
            children: [
              if (isWide)
                NavigationRail(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (i) =>
                      context.read<NavigationProvider>().goToTab(i),
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: 28,
                      color: AppTheme.accentGold,
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.receipt_long_outlined),
                      selectedIcon: Icon(Icons.receipt_long),
                      label: Text('Tracker'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bar_chart_outlined),
                      selectedIcon: Icon(Icons.bar_chart),
                      label: Text('Stats'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people_outline),
                      selectedIcon: Icon(Icons.people),
                      label: Text('Loans'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                ),
              Expanded(child: _screens[currentIndex]),
            ],
          ),
          bottomNavigationBar: isWide
              ? null
              : NavigationBar(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (i) =>
                      context.read<NavigationProvider>().goToTab(i),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: 'Dashboard',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.receipt_long_outlined),
                      selectedIcon: Icon(Icons.receipt_long),
                      label: 'Tracker',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.bar_chart_outlined),
                      selectedIcon: Icon(Icons.bar_chart),
                      label: 'Stats',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.people_outline),
                      selectedIcon: Icon(Icons.people),
                      label: 'Loans',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: 'Settings',
                    ),
                  ],
                ),
        );
      },
    );
  }
}
