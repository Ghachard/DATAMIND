import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme.dart';

class PieChartWidget extends StatefulWidget {
  final Map<String, dynamic> data;

  const PieChartWidget({super.key, required this.data});

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int? touchedIndex;

  static const _colors = [
    Color(0xFF1A6FD4),
    Color(0xFF00C8FF),
    Color(0xFF00E676),
    Color(0xFFAA00FF),
    Color(0xFFFFB300),
    Color(0xFFFF5252),
    Color(0xFF00BCD4),
    Color(0xFFFF9800),
  ];

  @override
  Widget build(BuildContext context) {
    final labels = List<String>.from(widget.data['labels'] ?? []);
    final values = List<double>.from(
      (widget.data['values'] ?? []).map((v) => (v as num).toDouble()),
    );
    final percentages = widget.data['percentages'] as List<dynamic>?;
    final title = widget.data['title'] ?? '';

    if (values.isEmpty) {
      return const Center(child: Text('Aucune donnée'));
    }

    final total = values.reduce((a, b) => a + b);

    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        enabled: true,
                        touchCallback: (event, response) {
                          setState(() {
                            if (event is FlLongPressEnd || event is FlPanEndEvent) {
                              touchedIndex = null;
                            } else if (response?.touchedSection != null) {
                              touchedIndex = response!.touchedSection!.touchedSectionIndex;
                            }
                          });
                        },
                      ),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: List.generate(values.length, (i) {
                        final isTouched = i == touchedIndex;
                        final radius = isTouched ? 60.0 : 50.0;
                        return PieChartSectionData(
                          value: values[i],
                          title: percentages != null
                              ? '${percentages[i]}%'
                              : '${(values[i] / total * 100).toStringAsFixed(1)}%',
                          radius: radius,
                          color: _colors[i % _colors.length],
                          titleStyle: TextStyle(
                            fontSize: isTouched ? 14 : 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(labels.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _colors[i % _colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              labels[i],
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
