import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/api_client.dart';
import '../providers/result_provider.dart';
import '../widgets/logo_header.dart';

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

    return Column(
      children: [
        const LogoHeader(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Row(
            children: [
              Text(
                'Analyse statistique',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              IconButton(
                icon: Icon(_showHistory ? Icons.close : Icons.history),
                onPressed: () => setState(() => _showHistory = !_showHistory),
                tooltip: 'Historique (5 dernières)',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_showHistory) ...[
            SizedBox(
              height: 120,
              child: _history.isEmpty
                  ? const Center(child: Text('Aucun historique'))
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
            Expanded(
              child: result.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : result.error != null
                      ? _buildError(result.error!)
                      : result.hasResult
                          ? _buildResults(result)
                          : _buildEmpty(),
            ),
          ],
        ],
      ),
    ),
    ),
  ],
);
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Color(0xFF666666)),
          const SizedBox(height: 16),
          Text('Aucun résultat', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Saisissez des données puis cliquez Calculer', style: TextStyle(color: Color(0xFF999999))),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
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
              Text('Erreur', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(error, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(ResultState result) {
    final stats = result.stats!;
    final entries = stats.entries.where((e) =>
        e.key != 'outliers' && e.key != 'z_scores' && e.key != 'class_midpoints' && e.key != 'cumulative_freq' &&
        e.key != 'is_normal' && e.key != 'normality_p_value' && e.key != 'data_type'
    ).toList();

    final statLabels = {
      'n': 'Effectif (n)',
      'mean': 'Moyenne',
      'median': 'Médiane',
      'mode': 'Mode',
      'variance': 'Variance',
      'std_dev': 'Écart-type',
      'cv': 'CV (%)',
      'min_val': 'Minimum',
      'max_val': 'Maximum',
      'range': 'Étendue',
      'sum': 'Somme',
      'q1': 'Q1',
      'q2': 'Q2 (Médiane)',
      'q3': 'Q3',
      'iqr': 'IQR',
      'skewness': 'Asymétrie',
      'kurtosis': 'Aplatissement',
      'sem': 'Erreur std',
      'pearson_r': 'r de Pearson',
      'r_squared': 'R²',
      'covariance': 'Covariance',
      'regression_slope': 'Pente (a)',
      'regression_intercept': 'Ordonnée (b)',
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
                  Text('Statistiques descriptives',
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
                                  ? 'Distribution normale (p = ${(stats['normality_p_value'] ?? 0.0).toStringAsFixed(4)})'
                                  : 'Distribution non-normale (p = ${(stats['normality_p_value'] ?? 0.0).toStringAsFixed(4)})',
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
                        Text('Interprétation',
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
                        '${(stats["outliers"] as List).length} valeur(s) aberrante(s) détectée(s)',
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
          ),
        ),
      ],
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
          Text(value, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
        ],
      ),
    );
  }
}
