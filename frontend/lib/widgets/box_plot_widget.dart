import 'package:flutter/material.dart';
import '../core/theme.dart';

class BoxPlotWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const BoxPlotWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final min = (data['min'] as num?)?.toDouble() ?? 0;
    final q1 = (data['q1'] as num?)?.toDouble() ?? 0;
    final median = (data['median'] as num?)?.toDouble() ?? 0;
    final q3 = (data['q3'] as num?)?.toDouble() ?? 0;
    final max = (data['max'] as num?)?.toDouble() ?? 0;
    final mean = (data['mean'] as num?)?.toDouble() ?? 0;
    final outliers = List<double>.from(
      (data['outliers'] ?? []).map((v) => (v as num).toDouble()),
    );
    final title = data['title'] ?? 'Boîte à moustaches';
    final iqr = (data['iqr'] as num?)?.toDouble() ?? 0;

    final range = max - min;
    final padding = range * 0.15;
    final plotMin = min - padding;
    final plotMax = max + padding;
    final plotRange = plotMax - plotMin;

    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onTapDown: (details) {
                          final x = details.localPosition.dx;
                          final value = plotMin + (x / constraints.maxWidth) * plotRange;
                          _showTooltip(context, details.globalPosition, value);
                        },
                        child: CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: _BoxPlotPainter(
                            min: min,
                            q1: q1,
                            median: median,
                            q3: q3,
                            max: max,
                            mean: mean,
                            outliers: outliers,
                            plotMin: plotMin,
                            plotMax: plotMax,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatsRow(context, min, q1, median, q3, max, mean, iqr),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showTooltip(BuildContext context, Offset globalPosition, double value) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        left: globalPosition.dx - 50,
        top: globalPosition.dy - 40,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Text(
              value.toStringAsFixed(2),
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  Widget _buildStatsRow(BuildContext context, double min, double q1, double median,
      double q3, double max, double mean, double iqr) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _statChip('Min', min.toStringAsFixed(2)),
        _statChip('Q1', q1.toStringAsFixed(2)),
        _statChip('Médiane', median.toStringAsFixed(2)),
        _statChip('Q3', q3.toStringAsFixed(2)),
        _statChip('Max', max.toStringAsFixed(2)),
        _statChip('Moyenne', mean.toStringAsFixed(2)),
        _statChip('IQR', iqr.toStringAsFixed(2)),
      ],
    );
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: AppColors.textDark, fontSize: 10)),
          Text(value, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

class _BoxPlotPainter extends CustomPainter {
  final double min, q1, median, q3, max, mean;
  final List<double> outliers;
  final double plotMin, plotMax;

  _BoxPlotPainter({
    required this.min,
    required this.q1,
    required this.median,
    required this.q3,
    required this.max,
    required this.mean,
    required this.outliers,
    required this.plotMin,
    required this.plotMax,
  });

  @override
  void paint(Canvas size, Canvas canvas) {
    final w = size.size.width;
    final h = size.size.height;
    final plotRange = plotMax - plotMin;

    double toX(double value) => ((value - plotMin) / plotRange) * w;
    final cy = h / 2;
    final boxHeight = h * 0.3;

    final boxPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final medianPaint = Paint()
      ..color = AppColors.success
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final outlierPaint = Paint()
      ..color = AppColors.error
      ..style = PaintingStyle.fill;

    final meanPaint = Paint()
      ..color = AppColors.warning
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(center: Offset(w / 2, cy), width: toX(q3) - toX(q1), height: boxHeight),
      boxPaint,
    );

    canvas.drawLine(Offset(toX(q1), cy - boxHeight / 2), Offset(toX(q1), cy + boxHeight / 2), linePaint);
    canvas.drawLine(Offset(toX(q3), cy - boxHeight / 2), Offset(toX(q3), cy + boxHeight / 2), linePaint);

    canvas.drawLine(Offset(toX(min), cy), Offset(toX(q1), cy), linePaint);
    canvas.drawLine(Offset(toX(q3), cy), Offset(toX(max), cy), linePaint);

    canvas.drawLine(Offset(toX(min), cy - boxHeight / 4), Offset(toX(min), cy + boxHeight / 4), linePaint);
    canvas.drawLine(Offset(toX(max), cy - boxHeight / 4), Offset(toX(max), cy + boxHeight / 4), linePaint);

    canvas.drawLine(Offset(toX(median), cy - boxHeight / 2), Offset(toX(median), cy + boxHeight / 2), medianPaint);

    canvas.drawCircle(Offset(toX(mean), cy), 5, meanPaint);

    for (final o in outliers) {
      canvas.drawCircle(Offset(toX(o), cy), 5, outlierPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BoxPlotPainter oldDelegate) => true;
}
