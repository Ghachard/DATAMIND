import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/api_client.dart';
import '../providers/data_provider.dart';
import '../providers/result_provider.dart';
import '../providers/app_state.dart';

class ProbabilityScreen extends ConsumerStatefulWidget {
  const ProbabilityScreen({super.key});

  @override
  ConsumerState<ProbabilityScreen> createState() => _ProbabilityScreenState();
}

class _ProbabilityScreenState extends ConsumerState<ProbabilityScreen> {
  String _selectedLaw = 'normal';
  final Map<String, TextEditingController> _controllers = {};
  final _xController = TextEditingController();
  final _xMinController = TextEditingController();
  final _xMaxController = TextEditingController();
  Map<String, dynamic>? _result;
  String? _chartImage;
  bool _isLoading = false;
  String? _error;

  final List<Map<String, dynamic>> _laws = [
    {'id': 'normal', 'name': 'Normale', 'nature': 'continuous', 'params': ['μ (moyenne)', 'σ (écart-type)'], 'paramKeys': ['mu', 'sigma']},
    {'id': 'uniform', 'name': 'Uniforme', 'nature': 'continuous', 'params': ['a (min)', 'b (max)'], 'paramKeys': ['a', 'b']},
    {'id': 'binomial', 'name': 'Binomiale', 'nature': 'discrete', 'params': ['n (essais)', 'p (probabilité)'], 'paramKeys': ['n', 'p']},
    {'id': 'poisson', 'name': 'Poisson', 'nature': 'discrete', 'params': ['λ (lambda)'], 'paramKeys': ['lambda']},
    {'id': 'bernoulli', 'name': 'Bernoulli', 'nature': 'discrete', 'params': ['p (probabilité)'], 'paramKeys': ['p']},
    {'id': 'chi2', 'name': 'Chi²', 'nature': 'continuous', 'params': ['k (ddl)'], 'paramKeys': ['k']},
  ];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _autoFillFromStats(Map<String, dynamic>? stats) {
    if (stats == null) return;

    final mean = stats['mean'];
    final stdDev = stats['std_dev'];
    final variance = stats['variance'];
    final n = stats['n'];
    final min = stats['min'];
    final max = stats['max'];

    if (mean != null) _controllers['normal_mu']?.text = mean.toStringAsFixed(2);
    if (stdDev != null) _controllers['normal_sigma']?.text = stdDev.toStringAsFixed(2);
    if (min != null) _controllers['uniform_a']?.text = min.toStringAsFixed(2);
    if (max != null) _controllers['uniform_b']?.text = max.toStringAsFixed(2);
    if (n != null) {
      _controllers['binomial_n']?.text = n.toString();
      _controllers['chi2_k']?.text = (n > 1 ? n - 1 : 1).toString();
    }
    if (mean != null && mean > 0) _controllers['poisson_lambda']?.text = mean.toStringAsFixed(2);
    if (variance != null && mean != null && mean > 0) {
      final p = variance / mean;
      if (p >= 0 && p <= 1) {
        _controllers['binomial_p']?.text = p.toStringAsFixed(2);
        _controllers['bernoulli_p']?.text = p.toStringAsFixed(2);
      }
    }
  }

  void _initControllers() {
    for (final law in _laws) {
      for (final param in law['paramKeys']) {
        _controllers['${law["id"]}_$param'] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _xController.dispose();
    _xMinController.dispose();
    _xMaxController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getParams() {
    final law = _laws.firstWhere((l) => l['id'] == _selectedLaw);
    final params = <String, dynamic>{};
    for (final key in law['paramKeys']) {
      final text = _controllers['${_selectedLaw}_$key']?.text ?? '';
      final val = double.tryParse(text);
      if (val == null) throw Exception('Paramètre $key invalide');
      if (key == 'n' || key == 'k') {
        params[key] = val.toInt();
      } else {
        params[key] = val;
      }
    }
    return params;
  }

  Future<void> _calculate() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final params = _getParams();
      final api = ref.read(apiClientProvider);
      final x = double.tryParse(_xController.text);
      final xMin = double.tryParse(_xMinController.text);
      final xMax = double.tryParse(_xMaxController.text);

      final result = await api.computeProbability(_selectedLaw, params,
          x: x, xMin: xMin, xMax: xMax);

      final chartResult = await api.generateChart('normal_curve',
          variableName: 'Loi $_selectedLaw');

      setState(() {
        _result = result;
        _chartImage = chartResult['image_base64'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildLawContent(Map<String, dynamic> currentLaw, ResultState result, Locale locale) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Paramètres — ${currentLaw['name']}',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                ...currentLaw['params'].asMap().entries.map((entry) {
                  final key = currentLaw['paramKeys'][entry.key];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: _controllers['${_selectedLaw}_$key'],
                      decoration: InputDecoration(
                        labelText: entry.value,
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  );
                }),
                if (result.hasResult)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 16, color: AppColors.accent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Paramètres pré-remplis avec vos données. Vous pouvez les modifier.',
                              style: TextStyle(fontSize: 12, color: AppColors.accent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const Divider(),
                Text('Calculs', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 400) {
                      return Column(
                        children: [
                          TextField(
                            controller: _xController,
                            decoration: const InputDecoration(
                                labelText: 'P(X = x) ou P(X ≤ x)', isDense: true),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _xMinController,
                                  decoration: const InputDecoration(
                                      labelText: 'x min', isDense: true),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _xMaxController,
                                  decoration: const InputDecoration(
                                      labelText: 'x max', isDense: true),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _xController,
                            decoration: const InputDecoration(
                                labelText: 'P(X = x) ou P(X ≤ x)', isDense: true),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _xMinController,
                            decoration: const InputDecoration(
                                labelText: 'x min', isDense: true),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _xMaxController,
                            decoration: const InputDecoration(
                                labelText: 'x max', isDense: true),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _calculate,
                    icon: const Icon(Icons.calculate),
                    label: Text(_isLoading ? AppStrings.tr('prob_loading', locale) : AppStrings.tr('prob_calculate', locale)),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_error != null)
          Card(
            color: AppColors.error.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: TextStyle(color: AppColors.error))),
                ],
              ),
            ),
          ),
        if (_result != null) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Résultats', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_result!['p_equal'] != null)
                        _resultChip('P(X = x)', _result!['p_equal']),
                      if (_result!['p_less_equal'] != null)
                        _resultChip('P(X ≤ x)', _result!['p_less_equal']),
                      if (_result!['p_interval'] != null)
                        _resultChip('P(a ≤ X ≤ b)', _result!['p_interval']),
                      _resultChip('Espérance', _result!['mean']),
                      _resultChip('Variance', _result!['variance']),
                      _resultChip('Écart-type', _result!['std_dev']),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_result!['interpretation'] != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_result!['interpretation']),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _resultChip(String label, dynamic value) {
    final display = value is double ? value.toStringAsFixed(6) : value.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Color(0xFF999999))),
          Text(display, style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider);
    final result = ref.watch(resultProvider);
    final locale = ref.watch(languageProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final natureStr = data.dataNature == DataNature.discrete ? 'discrete' : 'continuous';
    final availableLaws = _laws.where((l) => l['nature'] == natureStr).toList();

    if (!_laws.any((l) => l['id'] == _selectedLaw && l['nature'] == natureStr)) {
      if (availableLaws.isNotEmpty) _selectedLaw = availableLaws.first['id'];
    }

    if (result.hasResult) {
      _autoFillFromStats(result.stats);
    }

    final currentLaw = availableLaws.isNotEmpty
        ? availableLaws.firstWhere((l) => l['id'] == _selectedLaw)
        : _laws.first;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.tr('prob_title', locale), style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                if (!data.hasData)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.functions, size: 64, color: Color(0xFF666666)),
                          const SizedBox(height: 12),
                          Text(
                            ref.read(dataProvider).hasData
                                ? 'Sélectionnez une loi'
                                : 'Saisissez des données d\'abord',
                            style: TextStyle(color: Color(0xFF999999)),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (isMobile)
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 48,
                          child: availableLaws.isEmpty
                              ? Center(child: Text(AppStrings.tr('prob_empty', locale), style: TextStyle(color: Color(0xFF999999), fontSize: 12)))
                              : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: availableLaws.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                                  itemBuilder: (context, index) {
                                    final law = availableLaws[index];
                                    final isSelected = _selectedLaw == law['id'];
                                    return ChoiceChip(
                                      label: Text(law['name'], style: TextStyle(fontSize: 12)),
                                      selected: isSelected,
                                      onSelected: (_) => setState(() {
                                        _selectedLaw = law['id'];
                                        _result = null;
                                        _chartImage = null;
                                      }),
                                      selectedColor: AppColors.secondary,
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(child: _buildLawContent(currentLaw, result, locale)),
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 180,
                          child: availableLaws.isEmpty
                              ? Center(child: Text(AppStrings.tr('prob_empty', locale)))
                              : ListView.builder(
                                  itemCount: availableLaws.length,
                                  itemBuilder: (context, index) {
                                    final law = availableLaws[index];
                                    final isSelected = _selectedLaw == law['id'];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      color: isSelected ? AppColors.secondary : null,
                                      child: ListTile(
                                        title: Text(law['name'],
                                            style: TextStyle(
                                                color: isSelected ? Colors.white : null,
                                                fontWeight: isSelected ? FontWeight.w600 : null,
                                                fontSize: 14)),
                                        onTap: () => setState(() {
                                          _selectedLaw = law['id'];
                                          _result = null;
                                          _chartImage = null;
                                        }),
                                        dense: true,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: _buildLawContent(currentLaw, result, locale)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
