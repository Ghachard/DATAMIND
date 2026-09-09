import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/data_provider.dart';
import '../providers/result_provider.dart';
import '../providers/app_state.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  String? _historyError;

  Future<void> _loadHistory() async {
    try {
      final api = ref.read(apiClientProvider);
      final result = await api.getHistory();
      setState(() {
        _history = List<Map<String, dynamic>>.from(result['history'] ?? []);
        _historyError = null;
      });
    } catch (e) {
      setState(() => _historyError = 'Erreur chargement historique');
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(resultProvider);
    final data = ref.watch(dataProvider);
    final locale = ref.watch(languageProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final typeName = switch (data.type) {
      DataInputType.simple => AppStrings.tr('input_simple', locale),
      DataInputType.grouped => AppStrings.tr('input_grouped', locale),
      DataInputType.classes => AppStrings.tr('input_classes', locale),
      DataInputType.bivariate => AppStrings.tr('input_bivariate', locale),
    };
    final natureName = data.dataNature == DataNature.discrete
        ? AppStrings.tr('label_discrete', locale)
        : AppStrings.tr('label_continuous', locale);

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      AppStrings.tr('analysis_title', locale),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(_showHistory ? Icons.close : Icons.history),
                      onPressed: () => setState(() => _showHistory = !_showHistory),
                      tooltip: AppStrings.tr('btn_history', locale),
                    ),
                  ],
                ),
                if (data.hasData) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.data_object, size: 16, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Text(data.variableName, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.accent, fontSize: 13)),
                        const SizedBox(width: 12),
                        Text('$typeName · $natureName', style: TextStyle(color: Color(0xFF999999), fontSize: 12)),
                        const SizedBox(width: 12),
                        Text('${_getCount(data)} ${AppStrings.tr('input_entries', locale)}', style: TextStyle(color: Color(0xFF999999), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (_showHistory) ...[
                  SizedBox(
                    height: 120,
                    child: _history.isEmpty
                        ? Center(child: Text(AppStrings.tr('analysis_no_history', locale)))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _history.length,
                            itemBuilder: (context, index) {
                              final item = _history[index];
                              return Card(
                                margin: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () {},
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(item['data_type'] ?? '',
                                            style: TextStyle(color: AppColors.accent, fontSize: 11)),
                                        const SizedBox(height: 4),
                                        Text(item['variable_name'] ?? '',
                                            style: const TextStyle(fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 4),
                                        Text(item['created_at']?.substring(0, 16) ?? '',
                                            style: TextStyle(color: Color(0xFF999999), fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                ],
                Expanded(
                  child: result.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : result.error != null
                          ? _buildError(result.error!, locale)
                          : result.hasResult
                              ? _buildResults(result, locale)
                              : _buildEmpty(locale),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(Locale locale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Color(0xFF666666)),
          const SizedBox(height: 16),
          Text(AppStrings.tr('analysis_empty', locale), style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }

  Widget _buildError(String error, Locale locale) {
    return Center(
      child: Card(
        color: AppColors.error.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(AppStrings.tr('analysis_error_title', locale), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(error, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(ResultState result, Locale locale) {
    final stats = result.stats!;
    final entries = stats.entries.where((e) =>
        e.key != 'outliers' && e.key != 'z_scores' && e.key != 'class_midpoints' && e.key != 'cumulative_freq' &&
        e.key != 'is_normal' && e.key != 'normality_p_value' && e.key != 'data_type'
    ).toList();

    final statLabels = {
      'n': AppStrings.tr('label_n', locale),
      'mean': AppStrings.tr('label_mean', locale),
      'median': AppStrings.tr('label_median', locale),
      'mode': AppStrings.tr('label_mode', locale),
      'variance': AppStrings.tr('label_variance', locale),
      'std_dev': AppStrings.tr('label_std_dev', locale),
      'cv': AppStrings.tr('label_cv', locale),
      'min_val': AppStrings.tr('label_min', locale),
      'max_val': AppStrings.tr('label_max', locale),
      'range': AppStrings.tr('label_range', locale),
      'sum': AppStrings.tr('label_sum', locale),
      'q1': AppStrings.tr('label_q1', locale),
      'q2': AppStrings.tr('label_q2', locale),
      'q3': AppStrings.tr('label_q3', locale),
      'iqr': AppStrings.tr('label_iqr', locale),
      'skewness': AppStrings.tr('label_skewness', locale),
      'kurtosis': AppStrings.tr('label_kurtosis', locale),
      'sem': AppStrings.tr('label_sem', locale),
      'pearson_r': AppStrings.tr('label_pearson_r', locale),
      'r_squared': AppStrings.tr('label_r_squared', locale),
      'covariance': AppStrings.tr('label_covariance', locale),
      'regression_slope': AppStrings.tr('label_regression_slope', locale),
      'regression_intercept': AppStrings.tr('label_regression_intercept', locale),
    };

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.tr('export_stats', locale),
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  if (stats.containsKey('is_normal')) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (stats['is_normal'] == true)
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (stats['is_normal'] == true)
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            (stats['is_normal'] == true)
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: (stats['is_normal'] == true)
                                ? AppColors.success
                                : AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              (stats['is_normal'] == true)
                                  ? '${AppStrings.tr('analysis_normal', locale)} (p = ${(stats['normality_p_value'] ?? 0.0).toStringAsFixed(4)})'
                                  : '${AppStrings.tr('analysis_non_normal', locale)} (p = ${(stats['normality_p_value'] ?? 0.0).toStringAsFixed(4)})',
                              style: TextStyle(
                                color: (stats['is_normal'] == true)
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entries.map((e) {
                      final label = statLabels[e.key] ?? e.key;
                      final value = e.value is double
                          ? (e.value as double).toStringAsFixed(4)
                          : e.value.toString();
                      return _statChip(label, value);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          if (result.interpretation != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 20),
                        const SizedBox(width: 8),
                        Text(AppStrings.tr('analysis_interpretation', locale),
                            style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(result.interpretation!, style: const TextStyle(height: 1.6)),
                  ],
                ),
              ),
            ),
          ],
          if (stats['outliers'] != null && (stats['outliers'] as List).isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              color: AppColors.warning.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: AppColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${(stats["outliers"] as List).length} ${AppStrings.tr('analysis_outliers', locale)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Color(0xFF999999))),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
        ],
      ),
    );
  }

  int _getCount(DataState data) {
    switch (data.type) {
      case DataInputType.simple: return data.values.length;
      case DataInputType.grouped: return data.values.length;
      case DataInputType.classes: return data.lowerBounds.length;
      case DataInputType.bivariate: return data.xValues.length;
    }
  }
}
