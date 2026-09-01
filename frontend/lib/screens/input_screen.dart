import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/data_provider.dart';
import '../providers/app_state.dart';
import '../providers/result_provider.dart';
import '../widgets/logo_header.dart';

class InputScreen extends ConsumerStatefulWidget {
  const InputScreen({super.key});

  @override
  ConsumerState<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends ConsumerState<InputScreen> {
  final _textController = TextEditingController();
  final _nameController = TextEditingController(text: 'Variable');
  final _xNameController = TextEditingController(text: 'X');
  final _yNameController = TextEditingController(text: 'Y');

  @override
  void dispose() {
    _textController.dispose();
    _nameController.dispose();
    _xNameController.dispose();
    _yNameController.dispose();
    super.dispose();
  }

  void _parseData() {
    final data = ref.read(dataProvider);
    final text = _textController.text;
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
  }

  Future<void> _calculate() async {
    final data = ref.read(dataProvider);
    ref.read(dataProvider.notifier).setVariableName(_nameController.text);
    ref.read(dataProvider.notifier).setXName(_xNameController.text);
    ref.read(dataProvider.notifier).setYName(_yNameController.text);

    final dataNatureStr = data.dataNature == DataNature.discrete ? 'discrete' : 'continuous';
    final notifier = ref.read(resultProvider.notifier);
    switch (data.type) {
      case DataInputType.simple:
        await notifier.calculateSimple(data.values, _nameController.text, dataNature: dataNatureStr);
        final stats = ref.read(resultProvider).stats;
        if (stats != null) {
          ref.read(dataProvider.notifier).setNormalityTest(
            stats['is_normal'] ?? false,
            stats['normality_p_value'] ?? 0.0,
          );
        }
        break;
      case DataInputType.grouped:
        await notifier.calculateGrouped(data.values, data.frequencies, _nameController.text, dataNature: dataNatureStr);
        break;
      case DataInputType.classes:
        await notifier.calculateClasses(data.lowerBounds, data.upperBounds, data.frequencies, _nameController.text, dataNature: dataNatureStr);
        break;
      case DataInputType.bivariate:
        await notifier.calculateBivariate(data.xValues, data.yValues, _xNameController.text, _yNameController.text, dataNature: dataNatureStr);
        break;
    }
  }

  String _getHintText(DataInputType type) {
    switch (type) {
      case DataInputType.simple:
        return '12\n15\n18\n22\n25\n28\n30';
      case DataInputType.grouped:
        return '12\t5\n15\t8\n18\t12\n22\t7\n25\t3';
      case DataInputType.classes:
        return '10\t20\t5\n20\t30\t8\n30\t40\t12\n40\t50\t7';
      case DataInputType.bivariate:
        return '10\t25\n15\t30\n20\t35\n25\t40\n30\t45';
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider);
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
          Text(
            'Saisie des données',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<DataInputType>(
                  segments: [
                    ButtonSegment(value: DataInputType.simple, label: Text('Simple')),
                    ButtonSegment(value: DataInputType.grouped, label: Text('Groupée')),
                    ButtonSegment(value: DataInputType.classes, label: Text('Classes')),
                    ButtonSegment(value: DataInputType.bivariate, label: Text('Bivariée')),
                  ],
                  selected: {data.type},
                  onSelectionChanged: (selected) {
                    ref.read(dataProvider.notifier).setType(selected.first);
                    if (selected.first == DataInputType.classes) {
                      ref.read(dataProvider.notifier).setDataNature(DataNature.continuous);
                    }
                    _textController.clear();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<DataNature>(
                  segments: [
                    ButtonSegment(value: DataNature.discrete, label: Text('Discret')),
                    ButtonSegment(value: DataNature.continuous, label: Text('Continu')),
                  ],
                  selected: {data.dataNature},
                  onSelectionChanged: data.type == DataInputType.classes
                      ? null
                      : (selected) {
                          ref.read(dataProvider.notifier).setDataNature(selected.first);
                        },
                ),
              ),
            ],
          ),
          if (data.type == DataInputType.classes)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.accent),
                  const SizedBox(width: 6),
                  Text(
                    'Les données en classes sont intrinsèquement continues',
                    style: TextStyle(fontSize: 12, color: AppColors.accent),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nom de la variable'),
                ),
              ),
              if (data.type == DataInputType.bivariate) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _xNameController,
                    decoration: const InputDecoration(labelText: 'Nom X'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _yNameController,
                    decoration: const InputDecoration(labelText: 'Nom Y'),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Données',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  _getHintText(data.type),
                  style: TextStyle(color: Color(0xFF666666), fontSize: 12),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    onChanged: (_) => _parseData(),
                    decoration: InputDecoration(
                      hintText: _getHintText(data.type),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (data.hasData)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _statBadge('N', '${_getCount(data)}'),
                    const SizedBox(width: 12),
                    if (data.type == DataInputType.simple) ...[
                      _statBadge('Min', '${data.values.reduce((a, b) => a < b ? a : b)}'),
                      const SizedBox(width: 12),
                      _statBadge('Max', '${data.values.reduce((a, b) => a > b ? a : b)}'),
                    ],
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: result.isLoading ? null : _calculate,
                      icon: result.isLoading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.calculate),
                      label: Text(result.isLoading ? 'Calcul...' : 'Calculer'),
                    ),
                  ],
                ),
              ),
            ),
          if (result.error != null)
            Card(
              color: AppColors.error.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(child: Text(result.error!, style: const TextStyle(color: AppColors.error))),
                  ],
                ),
              ),
            ),
        ],
            ),
          ),
        ),
      ],
    );
  }

  int _getCount(DataState data) {
    switch (data.type) {
      case DataInputType.simple:
        return data.values.length;
      case DataInputType.grouped:
        return data.frequencies.fold(0, (sum, f) => sum + f);
      case DataInputType.classes:
        return data.frequencies.fold(0, (sum, f) => sum + f);
      case DataInputType.bivariate:
        return data.xValues.length;
    }
  }

  Widget _statBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('$label: $value', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
    );
  }
}
