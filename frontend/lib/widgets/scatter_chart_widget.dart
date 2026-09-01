import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme.dart';

class ScatterChartWidget extends StatefulWidget {
  final Map<String, dynamic> data;

  const ScatterChartWidget({super.key, required this.data});

  @override
  State<ScatterChartWidget> createState() => _ScatterChartWidgetState();
}

class _ScatterChartWidgetState extends State<ScatterChartWidget> {
  @override
  Widget build(BuildContext context) {
    final points = List<Map<String, dynamic>>.from(
      (widget.data['points'] ?? []).map((p) => Map<String, dynamic>.from(p)),
    );
    final regression = widget.data['regression'] as Map<String, dynamic>?;
    final title = widget.data['title'] ?? '';
    final xLabel = widget.data['x_label'] ?? 'X';
    final yLabel = widget.data['y_label'] ?? 'Y';

    if (points.isEmpty) {
      return const Center(child: Text('Aucune donnée'));
    }

    final chartPoints = points
        .map((p) => FlSpot(
              (p['x'] as num).toDouble(),
              (p['y'] as num).toDouble(),
            ))
        .toList();

    final allX = chartPoints.map((p) => p.x).toList();
    final allY = chartPoints.map((p) => p.y).toList();
    final minX = allX.reduce((a, b) => a < b ? a : b);
    final maxX = allX.reduce((a, b) => a > b ? a : b);
    final minY = allY.reduce((a, b) => a < b ? a : b);
    final maxY = allY.reduce((a, b) => a > b ? a : b);

    final xRange = maxX - minX;
    final yRange = maxY - minY;

    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (regression != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${regression['equation']}  r=${regression['r']}  R²=${regression['r_squared']}',
              style: TextStyle(color: AppColors.accent, fontSize: 12),
            ),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ScatterChart(
              ScatterChartData(
                minX: minX - xRange * 0.1,
                maxX: maxX + xRange * 0.1,
                minY: minY - yRange * 0.1,
                maxY: maxY + yRange * 0.1,
                scatterTouchData: ScatterTouchData(
                  enabled: true,
                  touchTooltipData: ScatterTouchTooltipData(
                    getTooltipItems: (touchedSpot) {
                      return ScatterTooltipItem(
                        'x: ${touchedSpot.x.toStringAsFixed(2)}\n',
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: 'y: ${touchedSpot.y.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: AppColors.borderDark, width: 1),
                ),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.borderDark.withAlpha(100),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: AppColors.borderDark.withAlpha(100),
                      strokeWidth: 1,
                    );
                  },
                ),
                scatterSpots: [
                  ScatterSpot(
                    0,
                    0,
                    show: false,
                  ),
                  ...chartPoints.map((p) => ScatterSpot(
                        p.x,
                        p.y,
                      )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
