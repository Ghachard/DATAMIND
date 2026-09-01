import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/app_state.dart';
import 'input_screen.dart';
import 'analysis_screen.dart';
import 'charts_screen.dart';
import 'probability_screen.dart';
import 'lessons_screen.dart';
import 'export_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final _screens = const [
    InputScreen(),
    AnalysisScreen(),
    ChartsScreen(),
    ProbabilityScreen(),
    LessonsScreen(),
    ExportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(languageProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'DM',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            trailing: Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      color: AppColors.accent,
                    ),
                    onPressed: () => ref.read(themeProvider.notifier).toggle(),
                    tooltip: AppStrings.tr('theme_toggle', locale),
                  ),
                  IconButton(
                    icon: const Icon(Icons.translate, color: AppColors.accent),
                    onPressed: () => ref.read(languageProvider.notifier).toggle(),
                    tooltip: AppStrings.tr('lang_toggle', locale),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.table_chart_outlined),
                selectedIcon: const Icon(Icons.table_chart),
                label: Text(AppStrings.tr('nav_input', locale)),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.bar_chart_outlined),
                selectedIcon: const Icon(Icons.bar_chart),
                label: Text(AppStrings.tr('nav_analysis', locale)),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.show_chart_outlined),
                selectedIcon: const Icon(Icons.show_chart),
                label: Text(AppStrings.tr('nav_charts', locale)),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.functions_outlined),
                selectedIcon: const Icon(Icons.functions),
                label: Text(AppStrings.tr('nav_probability', locale)),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.menu_book_outlined),
                selectedIcon: const Icon(Icons.menu_book),
                label: Text(AppStrings.tr('nav_lessons', locale)),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                selectedIcon: const Icon(Icons.picture_as_pdf),
                label: Text(AppStrings.tr('nav_export', locale)),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}
