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
    (_icon: Icons.table_chart_outlined, _selIcon: Icons.table_chart, _label: 'nav_input'),
    (_icon: Icons.bar_chart_outlined, _selIcon: Icons.bar_chart, _label: 'nav_analysis'),
    (_icon: Icons.show_chart_outlined, _selIcon: Icons.show_chart, _label: 'nav_charts'),
    (_icon: Icons.functions_outlined, _selIcon: Icons.functions, _label: 'nav_probability'),
    (_icon: Icons.menu_book_outlined, _selIcon: Icons.menu_book, _label: 'nav_lessons'),
    (_icon: Icons.picture_as_pdf_outlined, _selIcon: Icons.picture_as_pdf, _label: 'nav_export'),
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
                            icon: _destinations[i]._$1,
                            selectedIcon: _destinations[i]._$2,
                            label: AppStrings.tr(_destinations[i]._$3, locale),
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
