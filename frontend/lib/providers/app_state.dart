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
      'input_title': 'Saisie des données',
      'label_data_type': 'Type de données',
      'label_data_nature': 'Nature',
      'label_variable_name': 'Nom de la variable',
      'label_data': 'Données',
      'hint_simple': '12\n15\n18\n22\n25\n28\n30',
      'hint_grouped': '12\t5\n15\t8\n18\t12\n22\t7\n25\t3',
      'hint_classes': '10\t20\t5\n20\t30\t8\n30\t40\t12\n40\t50\t7',
      'hint_bivariate': '10\t25\n15\t30\n20\t35\n25\t40\n30\t45',
      'msg_no_data': 'Veuillez saisir des données.',
      'msg_no_data_valid': 'Veuillez saisir des données valides.',
      'msg_non_numeric': 'Valeur non numérique détectée :',
      'msg_enter_numbers': 'Entrez des nombres.',
      'classes_continuous_hint': 'Les données en classes sont intrinsèquement continues',
      'nav_variable': 'Variable',
      'analysis_title': 'Analyse statistique',
      'analysis_empty': 'Aucun résultat',
      'analysis_empty_hint': 'Saisissez des données puis cliquez Calculer',
      'analysis_no_history': 'Aucun historique',
      'analysis_interpretation': 'Interprétation',
      'analysis_normality': 'Test de normalité',
      'analysis_normal': 'Distribution normale',
      'analysis_non_normal': 'Distribution non normale',
      'export_title': 'Export PDF',
      'export_generate': 'Exporter en PDF',
      'export_generating': 'Génération...',
      'export_current_data': 'Données actuelles',
      'export_no_data': 'Aucune donnée à exporter',
      'export_sections': 'Sections du rapport',
      'export_stats': 'Statistiques descriptives',
      'export_stats_desc': 'Moyenne, médiane, variance, quartiles...',
      'export_charts': 'Graphiques',
      'export_charts_desc': 'Histogramme, boxplot, nuage de points...',
      'export_interp': 'Interprétation',
      'export_interp_desc': 'Texte pédagogique automatique',
      'export_normality_test': 'Test de normalité',
      'export_normality_desc': 'Shapiro-Wilk, interprétation',
      'charts_title': 'Graphiques',
      'charts_empty': 'Aucun graphique disponible',
      'charts_empty_hint': 'Saisissez et calculez des données d\'abord',
      'prob_title': 'Probabilités',
      'prob_empty': 'Aucune loi disponible',
      'prob_empty_hint': 'Saisissez des données d\'abord pour voir les lois',
      'prob_calculate': 'Calculer',
      'prob_loading': 'Calcul...',
      'input_graph_simple_discrete': 'Graphiques : Barres, Camembert, Polygone',
      'input_graph_simple_continuous': 'Graphiques : Histogramme, Boxplot, Barres, Courbe normale',
      'input_graph_grouped': 'Graphiques : Histogramme, Camembert, Polygone, Barres',
      'input_graph_classes': 'Graphiques : Histogramme jointif, Polygone, Ogive, Camembert',
      'input_graph_bivariate': 'Graphiques : Nuage de points, Droite de régression',
      'input_add_value': 'Ajouter une valeur',
      'input_add_class': 'Ajouter une classe',
      'input_add_pair': 'Ajouter une paire (X, Y)',
      'input_bulk': 'Saisie en masse',
      'input_entries': 'entrée',
      'input_entries_plural': 'entrées',
      'input_no_data': 'Aucune valeur saisie',
      'input_analyser': 'Analyser',
      'input_serie_name': 'Nom de la série',
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
      'input_title': 'Data Entry',
      'label_data_type': 'Data Type',
      'label_data_nature': 'Nature',
      'label_variable_name': 'Variable Name',
      'label_data': 'Data',
      'hint_simple': '12\n15\n18\n22\n25\n28\n30',
      'hint_grouped': '12\t5\n15\t8\n18\t12\n22\t7\n25\t3',
      'hint_classes': '10\t20\t5\n20\t30\t8\n30\t40\t12\n40\t50\t7',
      'hint_bivariate': '10\t25\n15\t30\n20\t35\n25\t40\n30\t45',
      'msg_no_data': 'Please enter data.',
      'msg_no_data_valid': 'Please enter valid data.',
      'msg_non_numeric': 'Non-numeric value detected:',
      'msg_enter_numbers': 'Enter numbers.',
      'classes_continuous_hint': 'Class data is inherently continuous',
      'nav_variable': 'Variable',
      'analysis_title': 'Statistical Analysis',
      'analysis_empty': 'No results',
      'analysis_empty_hint': 'Enter data then click Calculate',
      'analysis_no_history': 'No history',
      'analysis_interpretation': 'Interpretation',
      'analysis_normality': 'Normality test',
      'analysis_normal': 'Normal distribution',
      'analysis_non_normal': 'Non-normal distribution',
      'export_title': 'PDF Export',
      'export_generate': 'Export as PDF',
      'export_generating': 'Generating...',
      'export_current_data': 'Current data',
      'export_no_data': 'No data to export',
      'export_sections': 'Report sections',
      'export_stats': 'Descriptive statistics',
      'export_stats_desc': 'Mean, median, variance, quartiles...',
      'export_charts': 'Charts',
      'export_charts_desc': 'Histogram, box plot, scatter plot...',
      'export_interp': 'Interpretation',
      'export_interp_desc': 'Automatic pedagogical text',
      'export_normality_test': 'Normality test',
      'export_normality_desc': 'Shapiro-Wilk, interpretation',
      'charts_title': 'Charts',
      'charts_empty': 'No charts available',
      'charts_empty_hint': 'Enter and calculate data first',
      'prob_title': 'Probability',
      'prob_empty': 'No laws available',
      'prob_empty_hint': 'Enter data first to see available laws',
      'prob_calculate': 'Calculate',
      'prob_loading': 'Calculating...',
      'input_graph_simple_discrete': 'Charts: Bar chart, Pie chart, Polygon',
      'input_graph_simple_continuous': 'Charts: Histogram, Box plot, Bar chart, Normal curve',
      'input_graph_grouped': 'Charts: Histogram, Pie chart, Polygon, Bar chart',
      'input_graph_classes': 'Charts: Joint histogram, Polygon, Ogive, Pie chart',
      'input_graph_bivariate': 'Charts: Scatter plot, Regression line',
      'input_add_value': 'Add a value',
      'input_add_class': 'Add a class',
      'input_add_pair': 'Add a pair (X, Y)',
      'input_bulk': 'Bulk input',
      'input_entries': 'entry',
      'input_entries_plural': 'entries',
      'input_no_data': 'No values entered',
      'input_analyser': 'Analyze',
      'input_serie_name': 'Series name',
    },
  };

  static String tr(String key, Locale locale) {
    return _strings[locale.languageCode]?[key] ?? key;
  }
}
