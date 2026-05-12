import 'dart:math';

import 'package:flutter/material.dart';

class CustomMonthlyGraph extends StatelessWidget {
  final Map<int, Map<String, double>> dailyData;
  final int daysInMonth;

  const CustomMonthlyGraph({
    super.key,
    required this.dailyData,
    required this.daysInMonth,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final computedMax = _computeMax();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
        child: SizedBox(
          height: 200,
          child: dailyData.isEmpty
              ? Center(
                  child: Text(
                    'No data for this month',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                )
              : CustomPaint(
                  painter: _MonthlyGraphPainter(
                    dailyData: dailyData,
                    daysInMonth: daysInMonth,
                    maxValue: computedMax,
                    isDarkMode: isDark,
                  ),
                  size: const Size(double.infinity, 200),
                ),
        ),
      ),
    );
  }

  double _computeMax() {
    if (dailyData.isEmpty) return 1;
    double max = 0;
    for (final day in dailyData.values) {
      final total = (day['income'] ?? 0) + (day['outgoing'] ?? 0);
      if (total > max) max = total;
    }
    return max > 0 ? max * 1.2 : 1;
  }
}

class _MonthlyGraphPainter extends CustomPainter {
  final Map<int, Map<String, double>> dailyData;
  final int daysInMonth;
  final double maxValue;
  final bool isDarkMode;

  _MonthlyGraphPainter({
    required this.dailyData,
    required this.daysInMonth,
    required this.maxValue,
    required this.isDarkMode,
  });

  static const incomeColor = Color(0xFF4A90D9);
  static const outgoingColor = Color(0xFFE74C3C);

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 44.0;
    const rightPad = 12.0;
    const topPad = 8.0;
    const bottomPad = 32.0;

    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;
    if (chartWidth <= 0 || chartHeight <= 0) return;

    final gridColor =
        isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200;
    final textColor =
        isDarkMode ? Colors.white70 : Colors.black54;
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;
    final zeroPaint = Paint()
      ..color = isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400
      ..strokeWidth = 1;

    final yLabels = _generateYLabels();
    for (final yl in yLabels) {
      final y = topPad + chartHeight * (1 - yl.ratio);
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width - rightPad, y),
        yl.ratio == 0 ? zeroPaint : gridPaint,
      );
      _drawText(
        canvas,
        yl.label,
        Offset(leftPad - 6, y - 7),
        textColor,
        10,
        TextAlign.right,
      );
    }

    final slotWidth = chartWidth / daysInMonth;
    const barWidth = 8.0;
    const barGap = 2.0;

    for (int day = 1; day <= daysInMonth; day++) {
      final x = leftPad + (day - 1) * slotWidth + slotWidth / 2;

      final dayData = dailyData[day];
      final income = dayData?['income'] ?? 0;
      final outgoing = dayData?['outgoing'] ?? 0;

      if (income > 0) {
        final barH = (income / maxValue) * chartHeight;
        _drawBar(canvas, x - barWidth / 2 - barGap / 2, barWidth, barH,
            topPad + chartHeight, incomeColor);
      }
      if (outgoing > 0) {
        final barH = (outgoing / maxValue) * chartHeight;
        _drawBar(canvas, x + barGap / 2, barWidth, barH,
            topPad + chartHeight, outgoingColor);
      }

      if (day % 5 == 1 || day == daysInMonth) {
        _drawText(
          canvas,
          '$day',
          Offset(x - 6, topPad + chartHeight + 4),
          textColor,
          9,
          TextAlign.center,
        );
      }
    }

    _drawLegend(canvas, size, textColor);
  }

  void _drawBar(Canvas canvas, double x, double width, double height,
      double bottom, Color color) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, bottom - height, width, height),
      const Radius.circular(3),
    );
      canvas.drawRRect(
        rect,
        Paint()..color = color.withValues(alpha: 0.85),
      );
  }

  void _drawText(Canvas canvas, String text, Offset offset, Color color,
      double fontSize, TextAlign align) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout();
    tp.paint(canvas, offset);
  }

  void _drawLegend(Canvas canvas, Size size, Color textColor) {
    const legendY = 190.0;
    const startX = 16.0;

    canvas.drawCircle(const Offset(startX, legendY), 4, Paint()..color = incomeColor);
    _drawText(canvas, 'Income', const Offset(startX + 10, legendY - 7), textColor, 10,
        TextAlign.left);

    canvas.drawCircle(
        const Offset(startX + 70, legendY), 4, Paint()..color = outgoingColor);
    _drawText(canvas, 'Outgoing', const Offset(startX + 80, legendY - 7), textColor, 10,
        TextAlign.left);
  }

  List<_YLabel> _generateYLabels() {
    if (maxValue <= 0) return [];
    final step = _niceStep(maxValue / 4);
    final labels = <_YLabel>[];
    double v = 0;
    while (v <= maxValue + 0.01) {
      labels.add(_YLabel(v, _formatAmount(v), v / max(0.01, maxValue)));
      v += step;
    }
    return labels;
  }

  double _niceStep(double raw) {
    final exp = (log(raw) / ln10).floor();
    final frac = raw / pow(10, exp);
    double nice;
    if (frac <= 1.5) {
      nice = 1;
    } else if (frac <= 3.5) {
      nice = 2;
    } else if (frac <= 7.5) {
      nice = 5;
    } else {
      nice = 10;
    }
    return nice * pow(10, exp);
  }

  String _formatAmount(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  @override
  bool shouldRepaint(covariant _MonthlyGraphPainter oldDelegate) =>
      oldDelegate.dailyData != dailyData ||
      oldDelegate.maxValue != maxValue ||
      oldDelegate.isDarkMode != isDarkMode;
}

class _YLabel {
  final double value;
  final String label;
  final double ratio;

  _YLabel(this.value, this.label, this.ratio);
}
