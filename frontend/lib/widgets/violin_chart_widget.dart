import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'dart:math' as math;

class ViolinChartWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const ViolinChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final mu = data['mu'] as double;
    final sigma = data['sigma'] as double;
    final q1 = data['q1'] as double;
    final median = data['median'] as double;
    final q3 = data['q3'] as double;
    final minVal = data['min'] as double;
    final maxVal = data['max'] as double;
    final title = data['title'] as String;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                final centerX = w / 2;
                final violinWidth = w * 0.35;
                final range = maxVal - minVal;
                if (range == 0) return const Center(child: Text('Données constantes'));

                double y(double val) => h - ((val - minVal) / range) * (h * 0.8) - h * 0.1;

                return CustomPaint(
                  size: Size(w, h),
                  painter: _ViolinPainter(
                    centerX: centerX,
                    violinWidth: violinWidth,
                    mu: mu,
                    sigma: sigma,
                    q1: q1,
                    median: median,
                    q3: q3,
                    minVal: minVal,
                    maxVal: maxVal,
                    yFn: y,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildLegend(mu, sigma, q1, median, q3),
        ],
      ),
    );
  }

  Widget _buildLegend(double mu, double sigma, double q1, double median, double q3) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _legendItem('μ = ${mu.toStringAsFixed(2)}', AppColors.primary),
        _legendItem('σ = ${sigma.toStringAsFixed(2)}', AppColors.warning),
        _legendItem('Q1 = ${q1.toStringAsFixed(2)}', AppColors.success),
        _legendItem('Md = ${median.toStringAsFixed(2)}', AppColors.error),
        _legendItem('Q3 = ${q3.toStringAsFixed(2)}', AppColors.secondary),
      ],
    );
  }

  Widget _legendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _ViolinPainter extends CustomPainter {
  final double centerX;
  final double violinWidth;
  final double mu, sigma, q1, median, q3, minVal, maxVal;
  final double Function(double) yFn;

  _ViolinPainter({
    required this.centerX,
    required this.violinWidth,
    required this.mu,
    required this.sigma,
    required this.q1,
    required this.median,
    required this.q3,
    required this.minVal,
    required this.maxVal,
    required this.yFn,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final medianPaint = Paint()
      ..color = AppColors.error
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final quartilePaint = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    final muPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final range = maxVal - minVal;
    final sigmaNorm = sigma / range;

    final path = Path();
    const steps = 50;

    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final val = minVal + t * range;
      final z = (val - mu) / (sigma > 0 ? sigma : 1);
      final density = math.exp(-0.5 * z * z) / (math.sqrt(2 * math.pi));
      final halfWidth = (density / (1 / (math.sqrt(2 * math.pi) * (sigma > 0 ? sigma : 1)))) * violinWidth * 0.5;
      final yPos = yFn(val);

      if (i == 0) {
        path.moveTo(centerX - halfWidth, yPos);
      } else {
        path.lineTo(centerX - halfWidth, yPos);
      }
    }
    for (int i = steps; i >= 0; i--) {
      final t = i / steps;
      final val = minVal + t * range;
      final z = (val - mu) / (sigma > 0 ? sigma : 1);
      final density = math.exp(-0.5 * z * z) / (math.sqrt(2 * math.pi));
      final halfWidth = (density / (1 / (math.sqrt(2 * math.pi) * (sigma > 0 ? sigma : 1)))) * violinWidth * 0.5;
      final yPos = yFn(val);
      path.lineTo(centerX + halfWidth, yPos);
    }
    path.close();

    canvas.drawPath(path, bodyPaint);
    canvas.drawPath(path, borderPaint);

    canvas.drawLine(Offset(centerX - violinWidth * 0.3, yFn(median)), Offset(centerX + violinWidth * 0.3, yFn(median)), medianPaint);

    canvas.drawLine(Offset(centerX - violinWidth * 0.2, yFn(q1)), Offset(centerX + violinWidth * 0.2, yFn(q1)), quartilePaint);
    canvas.drawLine(Offset(centerX - violinWidth * 0.2, yFn(q3)), Offset(centerX + violinWidth * 0.2, yFn(q3)), quartilePaint);

    canvas.drawLine(Offset(centerX - violinWidth * 0.15, yFn(mu)), Offset(centerX + violinWidth * 0.15, yFn(mu)), muPaint);
  }

  @override
  bool shouldRepaint(covariant _ViolinPainter oldDelegate) => false;
}
