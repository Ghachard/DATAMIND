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

final currentSectionProvider = StateProvider<int>((ref) => 0);


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
      'input_simple': 'Simple',
      'input_grouped': 'Groupé',
      'input_classes': 'Classes',
      'input_bivariate': 'Bivarié',
      'btn_calculate': 'Calculer',
      'btn_export': 'Exporter PDF',
      'btn_history': 'Historique',
      'label_n': 'Effectif (n)',
      'label_mean': 'Moyenne',
      'label_median': 'Médiane',
      'label_mode': 'Mode',
      'label_variance': 'Variance',
      'label_std_dev': 'Écart-type',
      'label_cv': 'CV (%) — Coefficient de variation',
      'label_min': 'Minimum',
      'label_max': 'Maximum',
      'label_range': 'Étendue — Max − Min',
      'label_q1': 'Q1 — 1er quartile (25%)',
      'label_q2': 'Q2 — Médiane (50%)',
      'label_q3': 'Q3 — 3e quartile (75%)',
      'label_iqr': 'IQR — Écart interquartile',
      'label_sum': 'Somme',
      'label_skewness': 'Asymétrie',
      'label_kurtosis': 'Aplatissement',
      'label_sem': 'Erreur standard de la moyenne',
      'label_pearson_r': 'Corrélation de Pearson (r)',
      'label_r_squared': 'Coefficient de détermination (R²)',
      'label_covariance': 'Covariance',
      'label_regression_slope': 'Pente (a)',
      'label_regression_intercept': 'Ordonnée (b)',
      'empty_state': 'Aucune donnée saisie',
      'empty_hint': 'Saisissez vos données pour voir les résultats',
      'error_generic': 'Une erreur est survenue',
      'loading': 'Analyse en cours...',
      'theme_toggle': 'Thème',
      'lang_toggle': 'EN',
      'input_title': 'Saisie des données',
      'label_data_type': 'Type de données',
      'label_data_nature': 'Nature',
      'label_variable_name': 'Nom de la variable',
      'label_data': 'Données',
      'msg_no_data': 'Veuillez saisir des données.',
      'msg_no_data_valid': 'Veuillez saisir des données valides.',
      'classes_continuous_hint': 'Les données en classes sont intrinsèquement continues',
      'nav_variable': 'Variable',
      'analysis_title': 'Analyse statistique',
      'analysis_empty': 'Aucun résultat',
      'analysis_empty_hint': 'Saisissez des données puis cliquez Analyser',
      'analysis_no_history': 'Aucun historique',
      'analysis_interpretation': 'Interprétation',
      'analysis_normality': 'Test de normalité',
      'analysis_normal': 'Distribution normale',
      'analysis_non_normal': 'Distribution non normale',
      'analysis_error_title': 'Erreur',
      'analysis_outliers': 'valeur(s) aberrante(s) détectée(s)',
      'analysis_done': 'Analyse terminée. Consultez l\'onglet Analyse.',
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
      'export_subtitle': 'Générez un rapport PDF complet',
      'charts_title': 'Graphiques',
      'charts_empty': 'Aucun graphique disponible',
      'charts_empty_hint': 'Saisissez des données puis cliquez Analyser',
      'charts_type_label': 'Type',
      'charts_nature_label': 'Nature',
      'charts_select_type': 'Sélectionnez un type de graphique',
      'charts_no_data_hint': 'Saisissez des données d\'abord',
      'label_discrete': 'Discret',
      'label_continuous': 'Continu',
      'prob_title': 'Probabilités',
      'prob_empty': 'Aucune loi disponible',
      'prob_empty_hint': 'Saisissez des données pour voir les lois',
      'prob_calculate': 'Calculer',
      'prob_loading': 'Calcul...',
      'prob_parameters': 'Paramètres',
      'prob_prefilled_hint': 'Paramètres pré-remplis avec vos données. Vous pouvez les modifier.',
      'prob_calcs': 'Calculs',
      'prob_results': 'Résultats',
      'prob_select_law': 'Sélectionnez une loi',
      'input_add_value': 'Ajouter une valeur',
      'input_add_class': 'Ajouter une classe',
      'input_bulk': 'Saisie en masse',
      'input_entries': 'entrée',
      'input_entries_plural': 'entrées',
      'input_analyser': 'Analyser',
      'input_serie_name': 'Nom de la série',
      'btn_delete': 'Supprimer',
      'btn_cancel': 'Annuler',
      'btn_edit': 'Modifier',
      'lessons_subtitle': '9 chapitres pédagogiques',
      'lessons_definition': 'Définition',
      'lessons_formula': 'Formule',
      'lessons_interpretation': 'Interprétation',
      'lessons_remark': 'Remarque',
      'lessons_example': 'Exemple',
      'input_graph_simple_discrete': 'Barres, Camembert, Polygone',
      'input_graph_simple_continuous': 'Histogramme, Boxplot, Courbe normale',
      'input_graph_grouped': 'Histogramme, Camembert, Polygone',
      'input_graph_classes': 'Histogramme jointif, Ogive',
      'input_graph_bivariate': 'Nuage de points, Droite de régression',
    },
    'en': {
      'app_title': 'DataMind',
      'nav_input': 'Input',
      'nav_analysis': 'Analysis',
      'nav_charts': 'Charts',
      'nav_probability': 'Probability',
      'nav_lessons': 'Lessons',
      'nav_export': 'Export',
      'input_simple': 'Simple',
      'input_grouped': 'Grouped',
      'input_classes': 'Classes',
      'input_bivariate': 'Bivariate',
      'btn_calculate': 'Calculate',
      'btn_export': 'Export PDF',
      'btn_history': 'History',
      'label_n': 'Count (n)',
      'label_mean': 'Mean',
      'label_median': 'Median',
      'label_mode': 'Mode',
      'label_variance': 'Variance',
      'label_std_dev': 'Standard Deviation',
      'label_cv': 'CV (%) — Coefficient of Variation',
      'label_min': 'Minimum',
      'label_max': 'Maximum',
      'label_range': 'Range — Max − Min',
      'label_q1': 'Q1 — 1st quartile (25%)',
      'label_q2': 'Q2 — Median (50%)',
      'label_q3': 'Q3 — 3rd quartile (75%)',
      'label_iqr': 'IQR — Interquartile Range',
      'label_sum': 'Sum',
      'label_skewness': 'Skewness',
      'label_kurtosis': 'Kurtosis',
      'label_sem': 'Standard Error of the Mean',
      'label_pearson_r': 'Pearson Correlation (r)',
      'label_r_squared': 'Determination Coefficient (R²)',
      'label_covariance': 'Covariance',
      'label_regression_slope': 'Slope (a)',
      'label_regression_intercept': 'Intercept (b)',
      'empty_state': 'No data entered',
      'empty_hint': 'Enter your data to see results',
      'error_generic': 'An error occurred',
      'loading': 'Analyzing...',
      'theme_toggle': 'Theme',
      'lang_toggle': 'FR',
      'input_title': 'Data Entry',
      'label_data_type': 'Data Type',
      'label_data_nature': 'Nature',
      'label_variable_name': 'Variable Name',
      'label_data': 'Data',
      'msg_no_data': 'Please enter data.',
      'msg_no_data_valid': 'Please enter valid data.',
      'classes_continuous_hint': 'Class data is inherently continuous',
      'nav_variable': 'Variable',
      'analysis_title': 'Statistical Analysis',
      'analysis_empty': 'No results',
      'analysis_empty_hint': 'Enter data then click Analyze',
      'analysis_no_history': 'No history',
      'analysis_interpretation': 'Interpretation',
      'analysis_normality': 'Normality test',
      'analysis_normal': 'Normal distribution',
      'analysis_non_normal': 'Non-normal distribution',
      'analysis_error_title': 'Error',
      'analysis_outliers': 'outlier(s) detected',
      'analysis_done': 'Analysis complete. Check the Analysis tab.',
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
      'export_subtitle': 'Generate a complete PDF report',
      'charts_title': 'Charts',
      'charts_empty': 'No charts available',
      'charts_empty_hint': 'Enter data then click Analyze',
      'charts_type_label': 'Type',
      'charts_nature_label': 'Nature',
      'charts_select_type': 'Select a chart type',
      'charts_no_data_hint': 'Enter data first',
      'label_discrete': 'Discrete',
      'label_continuous': 'Continuous',
      'prob_title': 'Probability',
      'prob_empty': 'No laws available',
      'prob_empty_hint': 'Enter data to see available laws',
      'prob_calculate': 'Calculate',
      'prob_loading': 'Calculating...',
      'prob_parameters': 'Parameters',
      'prob_prefilled_hint': 'Parameters pre-filled with your data. You can modify them.',
      'prob_calcs': 'Calculations',
      'prob_results': 'Results',
      'prob_select_law': 'Select a law',
      'input_add_value': 'Add a value',
      'input_add_class': 'Add a class',
      'input_bulk': 'Bulk input',
      'input_entries': 'entry',
      'input_entries_plural': 'entries',
      'input_analyser': 'Analyze',
      'input_serie_name': 'Series name',
      'btn_delete': 'Delete',
      'btn_cancel': 'Cancel',
      'btn_edit': 'Edit',
      'lessons_subtitle': '9 pedagogical chapters',
      'lessons_definition': 'Definition',
      'lessons_formula': 'Formula',
      'lessons_interpretation': 'Interpretation',
      'lessons_remark': 'Remark',
      'lessons_example': 'Example',
      'input_graph_simple_discrete': 'Bar chart, Pie chart, Polygon',
      'input_graph_simple_continuous': 'Histogram, Box plot, Normal curve',
      'input_graph_grouped': 'Histogram, Pie chart, Polygon',
      'input_graph_classes': 'Joint histogram, Ogive',
      'input_graph_bivariate': 'Scatter plot, Regression line',
    },
  };

  static String tr(String key, Locale locale) {
    return _strings[locale.languageCode]?[key] ?? key;
  }
}
