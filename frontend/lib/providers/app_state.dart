import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.dark) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('dark_mode') ?? true;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', state == ThemeMode.dark);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});


class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('fr')) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('language') ?? 'fr';
    state = Locale(lang);
  }

  Future<void> toggle() async {
    state = state.languageCode == 'fr'
        ? const Locale('en')
        : const Locale('fr');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', state.languageCode);
  }

  String get currentLang => state.languageCode;
}

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});


class AppStrings {
  static Map<String, Map<String, String>> _strings = {
    'fr': {
      'app_title': 'DataMind',
      'nav_input': 'Saisie',
      'nav_analysis': 'Analyse',
      'nav_charts': 'Graphiques',
      'nav_probability': 'Probabilités',
      'nav_lessons': 'Leçons',
      'nav_export': 'Export',
      'input_simple': 'Données simples',
      'input_grouped': 'Données groupées',
      'input_classes': 'Données en classes',
      'input_bivariate': 'Données bivariées',
      'btn_calculate': 'Calculer',
      'btn_export': 'Exporter PDF',
      'btn_history': 'Historique',
      'label_mean': 'Moyenne',
      'label_median': 'Médiane',
      'label_mode': 'Mode',
      'label_variance': 'Variance',
      'label_std_dev': 'Écart-type',
      'label_cv': 'CV (%)',
      'label_min': 'Minimum',
      'label_max': 'Maximum',
      'label_range': 'Étendue',
      'label_q1': 'Q1',
      'label_q2': 'Q2',
      'label_q3': 'Q3',
      'label_iqr': 'IQR',
      'label_sum': 'Somme',
      'label_n': 'Effectif',
      'empty_state': 'Aucune donnée saisie',
      'empty_hint': 'Saisissez vos données pour voir les résultats',
      'error_generic': 'Une erreur est survenue',
      'loading': 'Calcul en cours...',
      'chart_histogram': 'Histogramme',
      'chart_boxplot': 'Boîte à moustaches',
      'chart_bar': 'Barres',
      'chart_pie': 'Camembert',
      'chart_scatter': 'Nuage de points',
      'theme_toggle': 'Thème',
      'lang_toggle': 'EN',
    },
    'en': {
      'app_title': 'DataMind',
      'nav_input': 'Input',
      'nav_analysis': 'Analysis',
      'nav_charts': 'Charts',
      'nav_probability': 'Probability',
      'nav_lessons': 'Lessons',
      'nav_export': 'Export',
      'input_simple': 'Simple data',
      'input_grouped': 'Grouped data',
      'input_classes': 'Class intervals',
      'input_bivariate': 'Bivariate data',
      'btn_calculate': 'Calculate',
      'btn_export': 'Export PDF',
      'btn_history': 'History',
      'label_mean': 'Mean',
      'label_median': 'Median',
      'label_mode': 'Mode',
      'label_variance': 'Variance',
      'label_std_dev': 'Std Dev',
      'label_cv': 'CV (%)',
      'label_min': 'Minimum',
      'label_max': 'Maximum',
      'label_range': 'Range',
      'label_q1': 'Q1',
      'label_q2': 'Q2',
      'label_q3': 'Q3',
      'label_iqr': 'IQR',
      'label_sum': 'Sum',
      'label_n': 'Count',
      'empty_state': 'No data entered',
      'empty_hint': 'Enter your data to see results',
      'error_generic': 'An error occurred',
      'loading': 'Calculating...',
      'chart_histogram': 'Histogram',
      'chart_boxplot': 'Box plot',
      'chart_bar': 'Bar chart',
      'chart_pie': 'Pie chart',
      'chart_scatter': 'Scatter plot',
      'theme_toggle': 'Theme',
      'lang_toggle': 'FR',
    },
  };

  static String tr(String key, Locale locale) {
    return _strings[locale.languageCode]?[key] ?? key;
  }
}
