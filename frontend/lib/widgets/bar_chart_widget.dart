import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme.dart';

class BarChartWidget extends StatefulWidget {
  final Map<String, dynamic> data;

  const BarChartWidget({super.key, required this.data});

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final labels = List<String>.from(widget.data['labels'] ?? []);
    final values = List<double>.from(
      (widget.data['values'] ?? []).map((v) => (v as num).toDouble()),
    );
    final title = widget.data['title'] ?? '';
    final mean = widget.data['mean'] as double?;

    if (values.isEmpty) {
      return const Center(child: Text('Aucune donnée'));
    }

    final maxY = values.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY * 1.3,
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${labels[groupIndex]}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: '${rod.toY.toStringAsFixed(1)}',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    touchCallback: (event, response) {
                      setState(() {
                        if (event is FlLongPressEnd || event is FlPanEndEvent) {
                          touchedIndex = null;
                        } else if (response?.spot != null) {
                          touchedIndex = response!.spot!.touchedBarGroupIndex;
                        }
                      });
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < labels.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                labels[idx],
                                style: TextStyle(color: AppColors.textDark, fontSize: 10),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        interval: _calcInterval(maxY),
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value % _calcInterval(maxY) != 0) {
                            if (value != 0) return const Text('');
                          }
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(color: AppColors.textDark, fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: AppColors.borderDark, width: 1),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _calcInterval(maxY),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.borderDark.withAlpha(80),
                        strokeWidth: 0.5,
                      );
                    },
                  ),
                  barGroups: List.generate(values.length, (i) {
                    final isTouched = i == touchedIndex;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: values[i],
                          color: isTouched ? AppColors.accent : AppColors.primary,
                          width: MediaQuery.of(context).size.width / (labels.length * 2),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY * 1.3,
                            color: AppColors.cardDark,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
        if (mean != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Moyenne = ${mean.toStringAsFixed(2)}',
              style: TextStyle(color: AppColors.accent, fontSize: 12),
            ),
          ),
      ],
    );
  }

  double _calcInterval(double maxY) {
    if (maxY <= 0) return 1;
    if (maxY <= 5) return 1;
    if (maxY <= 10) return 2;
    if (maxY <= 20) return 5;
    if (maxY <= 50) return 10;
    return (maxY / 5).ceilToDouble();
  }
}
