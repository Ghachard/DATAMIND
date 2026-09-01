import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/api_client.dart';
import '../providers/data_provider.dart';
import '../widgets/bar_chart_widget.dart';
import '../widgets/line_chart_widget.dart';
import '../widgets/scatter_chart_widget.dart';
import '../widgets/pie_chart_widget.dart';
import '../widgets/box_plot_widget.dart';
import '../widgets/violin_chart_widget.dart';
import '../widgets/logo_header.dart';

class ChartsScreen extends ConsumerStatefulWidget {
  const ChartsScreen({super.key});

  @override
  ConsumerState<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends ConsumerState<ChartsScreen> {
  String? _selectedChart;
  Map<String, dynamic>? _chartData;
  bool _isLoading = false;
  String? _error;

  final List<Map<String, dynamic>> _chartTypes = [
    {'id': 'histogram', 'name': 'Histogramme', 'icon': Icons.bar_chart, 'types': ['simple'], 'natures': ['continuous']},
    {'id': 'boxplot', 'name': 'Boîte à moustaches', 'icon': Icons.linear_scale, 'types': ['simple'], 'natures': ['continuous']},
    {'id': 'bar', 'name': 'Barres', 'icon': Icons.bar_chart, 'types': ['simple', 'grouped'], 'natures': ['discrete', 'continuous']},
    {'id': 'pie', 'name': 'Camembert', 'icon': Icons.pie_chart, 'types': ['simple', 'grouped'], 'natures': ['discrete', 'continuous']},
    {'id': 'scatter', 'name': 'Nuage de points', 'icon': Icons.scatter_plot, 'types': ['bivariate'], 'natures': ['discrete', 'continuous']},
    {'id': 'histogram_classes', 'name': 'Histogramme jointif', 'icon': Icons.chart_bar, 'types': ['classes'], 'natures': ['continuous']},
    {'id': 'ogive', 'name': 'Ogive', 'icon': Icons.trending_up, 'types': ['classes'], 'natures': ['continuous']},
    {'id': 'polygone', 'name': 'Polygone', 'icon': Icons.show_chart, 'types': ['grouped'], 'natures': ['discrete']},
    {'id': 'normal_curve', 'name': 'Courbe normale', 'icon': Icons.waves, 'types': ['simple'], 'natures': ['continuous']},
    {'id': 'violin', 'name': 'Violon', 'icon': Icons.graphic_eq, 'types': ['simple'], 'natures': ['continuous']},
  ];

  Future<void> _generateChart(String chartType) async {
    final data = ref.read(dataProvider);
    setState(() {
      _selectedChart = chartType;
      _isLoading = true;
      _error = null;
      _chartData = null;
    });

    try {
      final api = ref.read(apiClientProvider);
      final dataNatureStr = data.dataNature == DataNature.discrete ? 'discrete' : 'continuous';
      final result = await api.getChartData(
        chartType,
        values: data.type == DataInputType.simple ? data.values : null,
        frequencies: data.type == DataInputType.grouped || data.type == DataInputType.classes
            ? data.frequencies
            : null,
        lowerBounds: data.type == DataInputType.classes ? data.lowerBounds : null,
        upperBounds: data.type == DataInputType.classes ? data.upperBounds : null,
        x: data.type == DataInputType.bivariate ? data.xValues : null,
        y: data.type == DataInputType.bivariate ? data.yValues : null,
        variableName: data.variableName,
        dataNature: dataNatureStr,
      );
      setState(() {
        _chartData = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildChart() {
    if (_chartData == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.show_chart, size: 64, color: Color(0xFF666666)),
          const SizedBox(height: 12),
          Text(
            ref.read(dataProvider).hasData
                ? 'Sélectionnez un type de graphique'
                : 'Saisissez des données d\'abord',
            style: TextStyle(color: Color(0xFF999999)),
          ),
        ],
      );
    }

    final chartType = _chartData!['chart_type'] as String;

    switch (chartType) {
      case 'bar':
        return BarChartWidget(data: _chartData!);
      case 'line':
        return LineChartWidget(data: _chartData!);
      case 'scatter':
        return ScatterChartWidget(data: _chartData!);
      case 'pie':
        return PieChartWidget(data: _chartData!);
      case 'boxplot':
        return BoxPlotWidget(data: _chartData!);
      case 'violin':
        return ViolinChartWidget(data: _chartData!);
      default:
        return BarChartWidget(data: _chartData!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider);

    final dataTypeStr = switch (data.type) {
      DataInputType.simple => 'simple',
      DataInputType.grouped => 'grouped',
      DataInputType.classes => 'classes',
      DataInputType.bivariate => 'bivariate',
    };

    final dataNatureStr = data.dataNature == DataNature.discrete ? 'discrete' : 'continuous';

    final availableCharts = _chartTypes.where((c) {
      final types = c['types'] as List;
      final natures = c['natures'] as List;
      
      if (!types.contains(dataTypeStr)) return false;
      if (!natures.contains(dataNatureStr)) return false;

      if (c['id'] == 'normal_curve' && dataTypeStr == 'simple') {
        return data.isNormal;
      }
      if (c['id'] == 'violin' && dataTypeStr == 'simple') {
        return data.isNormal;
      }

      return true;
    }).toList();

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
            'Visualisation',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Type : $dataTypeStr  |  Nature : ${dataNatureStr == 'discrete' ? 'Discret' : 'Continu'}',
            style: TextStyle(color: Color(0xFF999999)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 220,
                  child: availableCharts.isEmpty
                      ? Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.info_outline, color: AppColors.warning, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  'Aucun graphique disponible pour ce type de données',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color(0xFF999999), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: availableCharts.length,
                          itemBuilder: (context, index) {
                            final chart = availableCharts[index];
                            final isSelected = _selectedChart == chart['id'];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              color: isSelected ? AppColors.primary : null,
                              child: ListTile(
                                leading: Icon(chart['icon'] as IconData,
                                    color: isSelected ? Colors.white : AppColors.accent),
                                title: Text(chart['name'] as String,
                                    style: TextStyle(
                                        color: isSelected ? Colors.white : null,
                                        fontWeight: isSelected ? FontWeight.w600 : null)),
                                onTap: data.hasData ? () => _generateChart(chart['id']) : null,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                                    const SizedBox(height: 12),
                                    Text(_error!, style: TextStyle(color: AppColors.error)),
                                  ],
                                ),
                              )
                            : _buildChart(),
                  ),
                ),
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
