import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../core/theme.dart';
import '../core/api_client.dart';
import '../providers/data_provider.dart';
import '../widgets/logo_header.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _includeStats = true;
  bool _includeCharts = true;
  bool _includeInterpretation = true;
  bool _isLoading = false;
  String? _error;
  String? _success;

  Future<void> _exportPdf() async {
    final data = ref.read(dataProvider);
    if (!data.hasData) {
      setState(() => _error = 'Aucune donnée à exporter');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      final api = ref.read(apiClientProvider);
      final dataTypeStr = switch (data.type) {
        DataInputType.simple => 'simple',
        DataInputType.grouped => 'grouped',
        DataInputType.classes => 'class_interval',
        DataInputType.bivariate => 'bivariate',
      };

      final requestData = <String, dynamic>{
        'data_type': dataTypeStr,
        'variable_name': data.variableName,
        'include_descriptive': _includeStats,
        'include_charts': _includeCharts,
        'include_interpretation': _includeInterpretation,
        'title': 'Rapport statistique — ${data.variableName}',
      };

      if (data.type == DataInputType.simple) requestData['values'] = data.values;
      if (data.type == DataInputType.grouped) {
        requestData['values'] = data.values;
        requestData['frequencies'] = data.frequencies;
      }
      if (data.type == DataInputType.classes) {
        requestData['lower_bounds'] = data.lowerBounds;
        requestData['upper_bounds'] = data.upperBounds;
        requestData['frequencies'] = data.frequencies;
      }
      if (data.type == DataInputType.bivariate) {
        requestData['x'] = data.xValues;
        requestData['y'] = data.yValues;
      }

      final pdfBytes = await api.exportPdf(requestData);

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toString().replaceAll(RegExp(r'[:.]'), '-').substring(0, 19);
      final filename = 'DataMind_${data.variableName}_$timestamp.pdf';
      final filePath = p.join(directory.path, filename);
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      setState(() {
        _isLoading = false;
        _success = 'PDF exporté : $filePath';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider);

    return Column(
      children: [
        const LogoHeader(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Text('Export PDF', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Générez un rapport PDF complet', style: TextStyle(color: Color(0xFF999999))),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sections du rapport', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Statistiques descriptives'),
                    subtitle: const Text('Moyenne, médiane, variance, quartiles...'),
                    value: _includeStats,
                    onChanged: (v) => setState(() => _includeStats = v),
                    activeColor: AppColors.primary,
                  ),
                  SwitchListTile(
                    title: const Text('Graphiques'),
                    subtitle: const Text('Histogramme, boxplot, nuage de points...'),
                    value: _includeCharts,
                    onChanged: (v) => setState(() => _includeCharts = v),
                    activeColor: AppColors.primary,
                  ),
                  SwitchListTile(
                    title: const Text('Interprétation'),
                    subtitle: const Text('Texte pédagogique automatique'),
                    value: _includeInterpretation,
                    onChanged: (v) => setState(() => _includeInterpretation = v),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.accent, size: 20),
                      const SizedBox(width: 8),
                      Text('Données actuelles', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _infoRow('Type', data.type.name),
                  _infoRow('Variable', data.variableName),
                  _infoRow('Points', '${_getCount(data)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_isLoading || !data.hasData) ? null : _exportPdf,
              icon: _isLoading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.picture_as_pdf),
              label: Text(_isLoading ? 'Génération...' : 'Exporter en PDF'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
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
          ],
          if (_success != null) ...[
            const SizedBox(height: 12),
            Card(
              color: AppColors.success.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_success!)),
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label : ', style: TextStyle(color: Color(0xFF999999))),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
