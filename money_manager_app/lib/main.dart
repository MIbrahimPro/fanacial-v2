import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'providers/loans_provider.dart';
import 'providers/monthly_tracker_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/sync_provider.dart';
import 'providers/theme_provider.dart';
import 'services/api_service.dart';
import 'services/connectivity_service.dart';
import 'services/hive_initializer.dart';
import 'services/pin_service.dart';
import 'services/storage_service.dart';
import 'services/sync_service.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';
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

  final connectivityService = ConnectivityService();
  await connectivityService.init();

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
        Provider.value(value: connectivityService),
        ChangeNotifierProvider(create: (_) {
          final api = ApiService(AppConstants.apiBaseUrl);
          final pin = PinService(FlutterSecureStorage());
          final sync = SyncService(api, connectivityService, pin);
          final sp = SyncProvider(sync, pin);
          sp.init();
          return sp;
        }),
      ],
      child: const MoneyManagerApp(),
    ),
  );
}

class MoneyManagerApp extends StatefulWidget {
  const MoneyManagerApp({super.key});

  @override
  State<MoneyManagerApp> createState() => _MoneyManagerAppState();
}

class _MoneyManagerAppState extends State<MoneyManagerApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await context.read<SyncProvider>().init();
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;

    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppTheme.accentGold),
          ),
        ),
      );
    }

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

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late PageController _pageController;

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
  void initState() {
    super.initState();
    final initialIndex = context.read<NavigationProvider>().currentIndex;
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = context.watch<NavigationProvider>();
    final currentIndex = navigationProvider.currentIndex;

    // Sync PageController with NavigationProvider
    if (_pageController.hasClients && _pageController.page?.round() != currentIndex) {
      _pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

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
                  onDestinationSelected: (i) {
                    navigationProvider.goToTab(i);
                    _pageController.jumpToPage(i);
                  },
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: themeMode == ThemeMode.dark ? AppTheme.darkSurface : AppTheme.creamyYellowLight,
                  useIndicator: true,
                  indicatorColor: AppTheme.accentGold.withValues(alpha: 0.2),
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: _HexagonDollarIcon(),
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
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => navigationProvider.goToTab(i),
                  children: _screens,
                ),
              ),
            ],
          ),
          bottomNavigationBar: isWide
              ? null
              : NavigationBar(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (i) {
                    navigationProvider.goToTab(i);
                    _pageController.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
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

class _HexagonDollarIcon extends StatelessWidget {
  const _HexagonDollarIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.accentGold,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGold.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '\$',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
