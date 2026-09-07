import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/app_state.dart';
import '../widgets/logo_header.dart';
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

  static const _destinations = [
    (icon: Icons.table_chart_outlined, selIcon: Icons.table_chart, label: 'nav_input'),
    (icon: Icons.bar_chart_outlined, selIcon: Icons.bar_chart, label: 'nav_analysis'),
    (icon: Icons.show_chart_outlined, selIcon: Icons.show_chart, label: 'nav_charts'),
    (icon: Icons.functions_outlined, selIcon: Icons.functions, label: 'nav_probability'),
    (icon: Icons.menu_book_outlined, selIcon: Icons.menu_book, label: 'nav_lessons'),
    (icon: Icons.picture_as_pdf_outlined, selIcon: Icons.picture_as_pdf, label: 'nav_export'),
  ];

  static const _screens = [
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;

    return Scaffold(
      body: Column(
        children: [
          const LogoHeader(),
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        for (int i = 0; i < _destinations.length; i++) ...[
                          _NavButton(
                            index: i,
                            selectedIndex: _selectedIndex,
                            icon: _destinations[i].icon,
                            selectedIcon: _destinations[i].selIcon,
                            label: AppStrings.tr(_destinations[i].label, locale),
                            isCompact: isCompact,
                            onTap: () => setState(() => _selectedIndex = i),
                          ),
                          const SizedBox(width: 2),
                        ],
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: AppColors.accent, size: 20),
                  onPressed: () => ref.read(themeProvider.notifier).toggle(),
                  tooltip: AppStrings.tr('theme_toggle', locale),
                ),
                IconButton(
                  icon: const Icon(Icons.translate, color: AppColors.accent, size: 20),
                  onPressed: () => ref.read(languageProvider.notifier).toggle(),
                  tooltip: AppStrings.tr('lang_toggle', locale),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isCompact;
  final VoidCallback onTap;

  const _NavButton({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isCompact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == selectedIndex;
    return Material(
      color: isActive ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 14, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? selectedIcon : icon,
                size: 20,
                color: isActive ? AppColors.accent : AppColors.textSecondary,
              ),
              if (!isCompact) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isActive ? AppColors.accent : AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
