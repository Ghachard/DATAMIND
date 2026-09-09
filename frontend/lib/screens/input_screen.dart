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

  @override
  void dispose() {
    _textController.dispose();
    _nameController.dispose();
    _singleValueController.dispose();
    _singleFreqController.dispose();
    _singleX2Controller.dispose();
    _singleFreqClassController.dispose();
    super.dispose();
  }

  bool _validateInput(String text, DataInputType type) {
    try {
      final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
      if (lines.isEmpty) return false;
      final firstValue = lines.first.trim().split(RegExp(r'[\t;,]+')).first.trim();
      if (double.tryParse(firstValue) == null) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  void _parseData() {
    final data = ref.read(dataProvider);
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    if (!_validateInput(text, data.type)) return;
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
    } catch (e) {}
  }

  void _addSingleValue() {
    final val = _singleValueController.text.trim();
    if (val.isEmpty) return;
    final numVal = double.tryParse(val);
    if (numVal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Valeur invalide'), backgroundColor: AppColors.error),
      );
      return;
    }

    final data = ref.read(dataProvider);
    final existing = _textController.text;

    switch (data.type) {
      case DataInputType.simple:
        _textController.text = existing.isEmpty ? '$numVal' : '$existing\n$numVal';
        break;
      case DataInputType.grouped:
        final freq = int.tryParse(_singleFreqController.text.trim());
        if (freq == null || freq <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Effectif invalide'), backgroundColor: AppColors.error),
          );
          return;
        }
        _textController.text = existing.isEmpty ? '$numVal\t$freq' : '$existing\n$numVal\t$freq';
        _singleFreqController.clear();
        break;
      case DataInputType.classes:
        final upper = double.tryParse(_singleFreqController.text.trim());
        if (upper == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Borne sup. invalide'), backgroundColor: AppColors.error),
          );
          return;
        }
        final freqStr = _singleFreqClassController.text.trim();
        final freqInt = int.tryParse(freqStr);
        if (freqInt == null || freqInt <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Effectif invalide'), backgroundColor: AppColors.error),
          );
          return;
        }
        _textController.text = '${existing.isEmpty ? '' : '$existing\n'}$numVal\t$upper\t$freqInt';
        _singleFreqController.clear();
        _singleFreqClassController.clear();
        break;
      case DataInputType.bivariate:
        final y = double.tryParse(_singleX2Controller.text.trim());
        if (y == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Valeur Y invalide'), backgroundColor: AppColors.error),
          );
          return;
        }
        _textController.text = existing.isEmpty ? '$numVal\t$y' : '$existing\n$numVal\t$y';
        _singleX2Controller.clear();
        break;
    }
    _singleValueController.clear();
    _parseData();
  }

  void _deleteEntry(int index) {
    final lines = _textController.text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (index < 0 || index >= lines.length) return;
    setState(() {
      lines.removeAt(index);
      _textController.text = lines.join('\n');
    });
    _parseData();
  }

  void _editEntry(int index) {
    final lines = _textController.text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (index < 0 || index >= lines.length) return;
    final editController = TextEditingController(text: lines[index]);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier'),
        content: TextField(
          controller: editController,
          autofocus: true,
          style: const TextStyle(fontFamily: 'monospace'),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              lines[index] = editController.text.trim();
              _textController.text = lines.join('\n');
              _parseData();
              Navigator.pop(ctx);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _calculate() async {
    _parseData();
    final data = ref.read(dataProvider);
    if (data.values.isEmpty && data.xValues.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saisissez des données valides.')),
      );
      return;
    }

    final varName = _nameController.text.trim().isEmpty ? 'Variable' : _nameController.text.trim();
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
          await notifier.calculateBivariate(data.xValues, data.yValues, 'X', 'Y', dataNature: dataNatureStr);
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur serveur. Réessayez.'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  String _getBulkHint() {
    switch (ref.read(dataProvider).type) {
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

  String _getGraphInfo() {
    final data = ref.read(dataProvider);
    final isDiscrete = data.dataNature == DataNature.discrete;
    final locale = ref.read(languageProvider);
    switch (data.type) {
      case DataInputType.simple:
        return isDiscrete ? AppStrings.tr('input_graph_simple_discrete', locale) : AppStrings.tr('input_graph_simple_continuous', locale);
      case DataInputType.grouped:
        return AppStrings.tr('input_graph_grouped', locale);
      case DataInputType.classes:
        return AppStrings.tr('input_graph_classes', locale);
      case DataInputType.bivariate:
        return AppStrings.tr('input_graph_bivariate', locale);
    }
  }

  String _getTypeName() {
    final locale = ref.read(languageProvider);
    switch (ref.read(dataProvider).type) {
      case DataInputType.simple:
        return AppStrings.tr('input_simple', locale);
      case DataInputType.grouped:
        return AppStrings.tr('input_grouped', locale);
      case DataInputType.classes:
        return AppStrings.tr('input_classes', locale);
      case DataInputType.bivariate:
        return AppStrings.tr('input_bivariate', locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider);
    final result = ref.watch(resultProvider);
    final locale = ref.watch(languageProvider);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.tr('label_data_type', locale), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent)),
                const SizedBox(height: 8),
                SegmentedButton<DataInputType>(
                  showSelectedIcon: false,
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
                    _singleFreqClassController.clear();
                  },
                ),
                if (data.type != DataInputType.classes) ...[
                  const SizedBox(height: 12),
                  Text(AppStrings.tr('label_data_nature', locale), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent)),
                  const SizedBox(height: 8),
                  SegmentedButton<DataNature>(
                    showSelectedIcon: false,
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
                if (data.type == DataInputType.classes)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(AppStrings.tr('classes_continuous_hint', locale), style: TextStyle(fontSize: 11, color: AppColors.accent)),
                  ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                  ),
                  child: Text(_getGraphInfo(), style: TextStyle(fontSize: 12, color: AppColors.accent)),
                ),
                const SizedBox(height: 16),
                Text(AppStrings.tr('input_serie_name', locale), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Ex: Notes des étudiants...',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  data.type == DataInputType.classes ? AppStrings.tr('input_add_class', locale) : AppStrings.tr('input_add_value', locale),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent),
                ),
                const SizedBox(height: 8),
                _buildSingleInputRow(data, locale),
                const SizedBox(height: 16),
                Text(AppStrings.tr('input_bulk', locale), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent)),
                const SizedBox(height: 8),
                TextField(
                  controller: _textController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 13),
                  onChanged: (_) => _parseData(),
                  decoration: InputDecoration(
                    hintText: _getBulkHint(),
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
                      decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        '${_getCount(data)} ${_getCount(data) > 1 ? AppStrings.tr('input_entries_plural', locale) : AppStrings.tr('input_entries', locale)}',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_getTypeName(), style: TextStyle(color: Color(0xFF999999), fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                _buildEntryList(data, locale),
                const SizedBox(height: 16),
                if (result.error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(result.error!, style: TextStyle(color: AppColors.error, fontSize: 12))),
                      ],
                    ),
                  ),
                if (result.hasResult)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(
                          AppStrings.tr('analysis_empty_hint', locale),
                          style: TextStyle(color: AppColors.success, fontSize: 12),
                        )),
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
            onPressed: result.isLoading ? null : _calculate,
            icon: result.isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.bar_chart, size: 20),
            label: Text(
              result.isLoading ? AppStrings.tr('loading', locale) : AppStrings.tr('input_analyser', locale),
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

  Widget _buildSingleInputRow(DataState data, Locale locale) {
    switch (data.type) {
      case DataInputType.simple:
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: _singleValueController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(hintText: 'Valeur xi', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
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
                decoration: const InputDecoration(hintText: 'Valeur xi', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _singleFreqController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(hintText: 'Effectif n', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
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
                decoration: const InputDecoration(hintText: 'Borne inf. (a)', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
              ),
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text(';', style: TextStyle(fontSize: 16, color: AppColors.accent))),
            Expanded(
              child: TextField(
                controller: _singleFreqController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(hintText: 'Borne sup. (b)', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: TextField(
                controller: _singleFreqClassController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(hintText: 'ni', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
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
                decoration: const InputDecoration(hintText: 'X', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _singleX2Controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(hintText: 'Y', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
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
      width: 44, height: 44,
      decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(10)),
      child: IconButton(icon: const Icon(Icons.add, color: Colors.white, size: 24), onPressed: _addSingleValue),
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

  Widget _buildEntryList(DataState data, Locale locale) {
    final text = _textController.text;
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: lines.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.borderDark),
        itemBuilder: (context, index) {
          final parts = lines[index].split(RegExp(r'[\t;,]+')).map((s) => s.trim()).toList();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    parts.join('  |  '),
                    style: TextStyle(fontSize: 12, color: Color(0xFFCCCCCC), fontFamily: 'monospace'),
                  ),
                ),
                GestureDetector(
                  onTap: () => _editEntry(index),
                  child: Icon(Icons.edit, size: 16, color: AppColors.accent),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _deleteEntry(index),
                  child: Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
