import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme.dart';

class LineChartWidget extends StatefulWidget {
  final Map<String, dynamic> data;

  const LineChartWidget({super.key, required this.data});

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  @override
  Widget build(BuildContext context) {
    final points = List<Map<String, dynamic>>.from(
      (widget.data['points'] ?? []).map((p) => Map<String, dynamic>.from(p)),
    );
    final title = widget.data['title'] ?? '';
    final xLabel = widget.data['x_label'] ?? '';
    final yLabel = widget.data['y_label'] ?? '';
    final zones = widget.data['zones'] as List<dynamic>?;
    final mu = widget.data['mu'] as double?;
    final sigma = widget.data['sigma'] as double?;

    if (points.isEmpty) {
      return const Center(child: Text('Aucune donnée'));
    }

    final chartPoints = points
        .map((p) => FlSpot(
              (p['x'] as num).toDouble(),
              (p['y'] as num).toDouble(),
            ))
        .toList();

    final minX = chartPoints.first.x;
    final maxX = chartPoints.last.x;
    final maxY = chartPoints.map((p) => p.y).reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY * 1.2,
                minX: minX,
                maxX: maxX,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          'x: ${spot.x.toStringAsFixed(2)}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: 'y: ${spot.y.toStringAsFixed(6)}',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: (maxX - minX) / 5,
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
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(4),
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 9,
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
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? maxY / 5 : 0.01,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.borderDark.withAlpha(100),
                      strokeWidth: 1,
                    );
                  },
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartPoints,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: AppColors.accent,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.accent.withAlpha(30),
                    ),
                  ),
                ],
                extraLinesData: mu != null && sigma != null
                    ? ExtraLinesData(
                        verticalLines: [
                          VerticalLine(
                            x: mu,
                            color: AppColors.success,
                            strokeWidth: 2,
                            dashArray: [6, 4],
                            label: VerticalLineLabel(
                              show: true,
                              labelResolver: (_) => 'μ=${mu.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
