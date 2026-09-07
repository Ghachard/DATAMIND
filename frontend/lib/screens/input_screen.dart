import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/data_provider.dart';
import '../providers/app_state.dart';
import '../providers/result_provider.dart';

class InputScreen extends ConsumerStatefulWidget {
  const InputScreen({super.key});

  @override
  ConsumerState<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends ConsumerState<InputScreen> {
  final _textController = TextEditingController();
  final _nameController = TextEditingController();
  final _singleValueController = TextEditingController();
  final _singleFreqController = TextEditingController();
  final _singleX2Controller = TextEditingController();
  final _singleFreqClassController = TextEditingController();
  final _bulkHintController = TextEditingController();

  String _singleValueHint() {
    final type = ref.read(dataProvider).type;
    switch (type) {
      case DataInputType.simple:
        return 'Valeur xi';
      case DataInputType.grouped:
        return 'Valeur xi';
      case DataInputType.classes:
        return 'Borne inf. (a)';
      case DataInputType.bivariate:
        return 'X';
    }
  }

  String _singleExtraHint() {
    final type = ref.read(dataProvider).type;
    switch (type) {
      case DataInputType.simple:
        return '';
      case DataInputType.grouped:
        return 'Effectif n';
      case DataInputType.classes:
        return 'Borne sup. (b)';
      case DataInputType.bivariate:
        return 'Y';
    }
  }

  String _bulkHint() {
    final type = ref.read(dataProvider).type;
    switch (type) {
      case DataInputType.simple:
        return 'Ex: 12, 15, 8.5, 20, 17.3';
      case DataInputType.grouped:
        return 'Ex: 12\t5\n15\t8\n18\t12';
      case DataInputType.classes:
        return 'Ex: 10\t20\t5\n20\t30\t8';
      case DataInputType.bivariate:
        return 'Ex: 10\t25\n15\t30\n20\t35';
    }
  }

  String _graphInfo() {
    final data = ref.read(dataProvider);
    final isDiscrete = data.dataNature == DataNature.discrete;
    switch (data.type) {
      case DataInputType.simple:
        return isDiscrete
            ? 'Graphiques : Barres, Camembert, Polygone'
            : 'Graphiques : Histogramme, Boxplot, Barres, Courbe normale';
      case DataInputType.grouped:
        return isDiscrete
            ? 'Graphiques : Histogramme, Camembert, Polygone, Barres'
            : 'Graphiques : Histogramme, Camembert, Polygone, Barres';
      case DataInputType.classes:
        return 'Graphiques : Histogramme jointif, Polygone, Ogive, Camembert';
      case DataInputType.bivariate:
        return 'Graphiques : Nuage de points, Droite de régression';
    }
  }

  String _typeName() {
    final type = ref.read(dataProvider).type;
    switch (type) {
      case DataInputType.simple:
        return 'Simple';
      case DataInputType.grouped:
        return 'Groupé';
      case DataInputType.classes:
        return 'Classes';
      case DataInputType.bivariate:
        return 'Bivarié';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _nameController.dispose();
    _singleValueController.dispose();
    _singleFreqController.dispose();
    _singleX2Controller.dispose();
    _singleFreqClassController.dispose();
    _bulkHintController.dispose();
    super.dispose();
  }

  bool _validateInput(String text, DataInputType type, Locale locale) {
    try {
      final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
      if (lines.isEmpty) return false;

      final sample = lines.first.trim();
      final firstValue = sample.split(RegExp(r'[\t;,]+')).first.trim();

      if (double.tryParse(firstValue) == null) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  void _parseData(Locale locale) {
    final data = ref.read(dataProvider);
    final text = _textController.text;
    if (text.trim().isEmpty) return;

    if (!_validateInput(text, data.type, locale)) return;

    try {
      switch (data.type) {
        case DataInputType.simple:
          ref.read(dataProvider.notifier).parseSimpleFromText(text);
          break;
        case DataInputType.grouped:
          ref.read(dataProvider.notifier).parseGroupedFromText(text);
          break;
        case DataInputType.classes:
          ref.read(dataProvider.notifier).parseClassFromText(text);
          break;
        case DataInputType.bivariate:
          ref.read(dataProvider.notifier).parseBivariateFromText(text);
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de parsing: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _addSingleValue() {
    final val = _singleValueController.text.trim();
    if (val.isEmpty) return;

    final numVal = double.tryParse(val);
    if (numVal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Valeur non numérique: "$val"'), backgroundColor: AppColors.error),
      );
      return;
    }

    final data = ref.read(dataProvider);
    final type = data.type;
    final existing = _textController.text;

    switch (type) {
      case DataInputType.simple:
        final line = existing.isEmpty ? '$numVal' : '$existing\n$numVal';
        _textController.text = line;
        break;
      case DataInputType.grouped:
        final freq = _singleFreqController.text.trim();
        final freqInt = int.tryParse(freq);
        if (freqInt == null || freqInt <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Effectif invalide'), backgroundColor: AppColors.error),
          );
          return;
        }
        final line = existing.isEmpty ? '$numVal\t$freqInt' : '$existing\n$numVal\t$freqInt';
        _textController.text = line;
        _singleFreqController.clear();
        break;
      case DataInputType.classes:
        final upper = _singleFreqController.text.trim();
        final upperVal = double.tryParse(upper);
        if (upperVal == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Borne supérieure invalide'), backgroundColor: AppColors.error),
          );
          return;
        }
        final freqStr = _singleFreqClassController.text.trim();
        final freqInt = int.tryParse(freqStr);
        if (freqInt == null || freqInt <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Effectif invalide'), backgroundColor: AppColors.error),
          );
          return;
        }
        final nLine = '${existing.isEmpty ? '' : '$existing\n'}$numVal\t$upperVal\t$freqInt';
        _textController.text = nLine;
        _singleFreqController.clear();
        _singleFreqClassController.clear();
        break;
      case DataInputType.bivariate:
        final y = _singleX2Controller.text.trim();
        final yVal = double.tryParse(y);
        if (yVal == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Valeur Y invalide'), backgroundColor: AppColors.error),
          );
          return;
        }
        final line = existing.isEmpty ? '$numVal\t$yVal' : '$existing\n$numVal\t$yVal';
        _textController.text = line;
        _singleX2Controller.clear();
        break;
    }

    _singleValueController.clear();
    _parseData(ref.read(languageProvider));
  }

  Future<void> _calculate(Locale locale) async {
    _parseData(locale);
    final data = ref.read(dataProvider);
    if (data.values.isEmpty && data.xValues.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.tr('msg_no_data_valid', locale))),
      );
      return;
    }

    final varName = _nameController.text.trim().isEmpty ? 'Variable' : _nameController.text.trim();
    final xName = 'X';
    final yName = 'Y';

    ref.read(dataProvider.notifier).setVariableName(varName);

    final dataNatureStr = data.dataNature == DataNature.discrete ? 'discrete' : 'continuous';
    final notifier = ref.read(resultProvider.notifier);
    try {
      switch (data.type) {
        case DataInputType.simple:
          await notifier.calculateSimple(data.values, varName, dataNature: dataNatureStr);
          final stats = ref.read(resultProvider).stats;
          if (stats != null) {
            ref.read(dataProvider.notifier).setNormalityTest(
              stats['is_normal'] ?? false,
              stats['normality_p_value'] ?? 0.0,
            );
          }
          break;
        case DataInputType.grouped:
          await notifier.calculateGrouped(data.values, data.frequencies, varName, dataNature: dataNatureStr);
          break;
        case DataInputType.classes:
          await notifier.calculateClasses(data.lowerBounds, data.upperBounds, data.frequencies, varName, dataNature: dataNatureStr);
          break;
        case DataInputType.bivariate:
          await notifier.calculateBivariate(data.xValues, data.yValues, xName, yName, dataNature: dataNatureStr);
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  int _getCount(DataState data) {
    switch (data.type) {
      case DataInputType.simple:
        return data.values.length;
      case DataInputType.grouped:
        return data.values.length;
      case DataInputType.classes:
        return data.lowerBounds.length;
      case DataInputType.bivariate:
        return data.xValues.length;
    }
  }

  String _getDataPreview(DataState data) {
    if (!data.hasData) return '';
    switch (data.type) {
      case DataInputType.simple:
        return data.values.join(', ');
      case DataInputType.grouped:
        return data.values.asMap().entries.map((e) => '${e.value}\t${data.frequencies[e.key]}').join('\n');
      case DataInputType.classes:
        return data.lowerBounds.asMap().entries.map((e) => '${e.value}\t${data.upperBounds[e.key]}\t${data.frequencies[e.key]}').join('\n');
      case DataInputType.bivariate:
        return data.xValues.asMap().entries.map((e) => '${e.value}\t${data.yValues[e.key]}').join('\n');
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider);
    final result = ref.watch(resultProvider);
    final locale = ref.watch(languageProvider);

    final count = _getCount(data);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type de données', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent)),
                const SizedBox(height: 8),
                SegmentedButton<DataInputType>(
                  segments: [
                    ButtonSegment(value: DataInputType.simple, label: Text('Simple')),
                    ButtonSegment(value: DataInputType.grouped, label: Text('Groupé')),
                    ButtonSegment(value: DataInputType.classes, label: Text('Classes [a;b]')),
                    ButtonSegment(value: DataInputType.bivariate, label: Text('Bivarié (X,Y)')),
                  ],
                  selected: {data.type},
                  onSelectionChanged: (selected) {
                    ref.read(dataProvider.notifier).setType(selected.first);
                    if (selected.first == DataInputType.classes) {
                      ref.read(dataProvider.notifier).setDataNature(DataNature.continuous);
                    }
                    _textController.clear();
                    _singleValueController.clear();
                    _singleFreqController.clear();
                    _singleX2Controller.clear();
                  },
                ),
                if (data.type != DataInputType.classes) ...[
                  const SizedBox(height: 12),
                  Text('Nature des données', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent)),
                  const SizedBox(height: 8),
                  SegmentedButton<DataNature>(
                    segments: [
                      ButtonSegment(value: DataNature.discrete, label: Text('Discret')),
                      ButtonSegment(value: DataNature.continuous, label: Text('Continu')),
                    ],
                    selected: {data.dataNature},
                    onSelectionChanged: (selected) {
                      ref.read(dataProvider.notifier).setDataNature(selected.first);
                    },
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _graphInfo(),
                          style: TextStyle(fontSize: 12, color: AppColors.accent),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('Nom de la série', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Ex: Notes des étudiants...',
                    prefixIcon: Icon(Icons.label_outline, size: 18, color: AppColors.accent),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  data.type == DataInputType.classes ? 'Ajouter une classe' : 'Ajouter une valeur',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent),
                ),
                const SizedBox(height: 8),
                _buildSingleInputRow(data),
                const SizedBox(height: 16),
                Text('Saisie en masse', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent)),
                const SizedBox(height: 8),
                TextField(
                  controller: _textController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 13),
                  onChanged: (_) => _parseData(locale),
                  decoration: InputDecoration(
                    hintText: _bulkHint(),
                    hintStyle: TextStyle(color: Color(0xFF666666), fontSize: 12),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count entrée${count > 1 ? 's' : ''}',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_typeName(), style: TextStyle(color: Color(0xFF999999), fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                if (data.hasData)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Text(
                      _getDataPreview(data),
                      style: TextStyle(fontSize: 12, color: Color(0xFFCCCCCC)),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Text(
                      'Aucune valeur saisie',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                    ),
                  ),
                const SizedBox(height: 8),
                if (result.error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(result.error!, style: TextStyle(color: AppColors.error, fontSize: 12))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(color: AppColors.borderDark, width: 0.5)),
          ),
          child: ElevatedButton.icon(
            onPressed: result.isLoading ? null : () => _calculate(locale),
            icon: result.isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.bar_chart, size: 20),
            label: Text(
              result.isLoading ? AppStrings.tr('loading', locale) : 'Analyser',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleInputRow(DataState data) {
    switch (data.type) {
      case DataInputType.simple:
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: _singleValueController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: _singleValueHint(),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onSubmitted: (_) => _addSingleValue(),
              ),
            ),
            const SizedBox(width: 8),
            _addButton(),
          ],
        );
      case DataInputType.grouped:
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: _singleValueController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: _singleValueHint(),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _singleFreqController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: _singleExtraHint(),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onSubmitted: (_) => _addSingleValue(),
              ),
            ),
            const SizedBox(width: 8),
            _addButton(),
          ],
        );
      case DataInputType.classes:
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: _singleValueController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Borne inf. (a)',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(';', style: TextStyle(fontSize: 16, color: AppColors.accent)),
            ),
            Expanded(
              child: TextField(
                controller: _singleFreqController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Borne sup. (b)',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: TextField(
                controller: _singleFreqClassController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'ni',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
                onSubmitted: (_) => _addSingleValue(),
              ),
            ),
            const SizedBox(width: 8),
            _addButton(),
          ],
        );
      case DataInputType.bivariate:
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: _singleValueController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'X',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _singleX2Controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Y',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onSubmitted: (_) => _addSingleValue(),
              ),
            ),
            const SizedBox(width: 8),
            _addButton(),
          ],
        );
    }
  }

  Widget _addButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: const Icon(Icons.add, color: Colors.white, size: 24),
        onPressed: _addSingleValue,
      ),
    );
  }
}
