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
    final cumulativeData = _computeCumulativeData();
    final yRange = _computeYRange(cumulativeData);

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
                  painter: _MonthlyLineGraphPainter(
                    cumulativeData: cumulativeData,
                    daysInMonth: daysInMonth,
                    yMin: yRange['min']!,
                    yMax: yRange['max']!,
                    isDarkMode: isDark,
                  ),
                  size: const Size(double.infinity, 200),
                ),
        ),
      ),
    );
  }

  Map<int, double> _computeCumulativeData() {
    final result = <int, double>{};
    double current = 0;
    for (int i = 1; i <= daysInMonth; i++) {
      final day = dailyData[i];
      if (day != null) {
        current += (day['income'] ?? 0) - (day['outgoing'] ?? 0);
      }
      result[i] = current;
    }
    return result;
  }

  Map<String, double> _computeYRange(Map<int, double> data) {
    if (data.isEmpty) return {'min': 0, 'max': 100};
    double minV = 0;
    double maxV = 0;
    for (final v in data.values) {
      if (v < minV) minV = v;
      if (v > maxV) maxV = v;
    }
    
    // Add some padding
    final range = maxV - minV;
    final padding = range == 0 ? 100.0 : range * 0.2;
    return {
      'min': minV - padding,
      'max': maxV + padding,
    };
  }
}

class _MonthlyLineGraphPainter extends CustomPainter {
  final Map<int, double> cumulativeData;
  final int daysInMonth;
  final double yMin;
  final double yMax;
  final bool isDarkMode;

  _MonthlyLineGraphPainter({
    required this.cumulativeData,
    required this.daysInMonth,
    required this.yMin,
    required this.yMax,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 48.0;
    const rightPad = 12.0;
    const topPad = 8.0;
    const bottomPad = 32.0;

    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;
    if (chartWidth <= 0 || chartHeight <= 0) return;

    final gridColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final textColor = isDarkMode ? Colors.white70 : Colors.black54;
    
    // Draw Y axis labels and grid
    final yLabels = _generateYLabels();
    for (final label in yLabels) {
      final y = _getYPos(label.value, chartHeight) + topPad;
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width - rightPad, y),
        Paint()..color = gridColor..strokeWidth = 0.5,
      );
      _drawText(canvas, label.label, Offset(leftPad - 6, y - 7), textColor, 9, TextAlign.right);
    }

    // Draw Zero line
    if (yMin < 0 && yMax > 0) {
      final zeroY = _getYPos(0, chartHeight) + topPad;
      canvas.drawLine(
        Offset(leftPad, zeroY),
        Offset(size.width - rightPad, zeroY),
        Paint()..color = isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400..strokeWidth = 1,
      );
    }

    final slotWidth = chartWidth / (daysInMonth - 1);
    final path = Path();
    final fillPath = Path();
    
    bool first = true;
    for (int i = 1; i <= daysInMonth; i++) {
      final x = leftPad + (i - 1) * slotWidth;
      final val = cumulativeData[i] ?? 0;
      final y = _getYPos(val, chartHeight) + topPad;

      if (first) {
        path.moveTo(x, y);
        fillPath.moveTo(x, _getYPos(0, chartHeight) + topPad);
        fillPath.lineTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      
      // X labels
      if (i % 5 == 1 || i == daysInMonth) {
        _drawText(canvas, '$i', Offset(x - 6, topPad + chartHeight + 6), textColor, 9, TextAlign.center);
      }
    }

    // Draw fill
    fillPath.lineTo(leftPad + (daysInMonth - 1) * slotWidth, _getYPos(0, chartHeight) + topPad);
    fillPath.close();
    
    final accentColor = const Color(0xFFFFD700);
    canvas.drawPath(fillPath, Paint()..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [accentColor.withValues(alpha: 0.3), accentColor.withValues(alpha: 0.0)],
    ).createShader(Rect.fromLTWH(leftPad, topPad, chartWidth, chartHeight)));

    // Draw line
    canvas.drawPath(path, Paint()
      ..color = accentColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    _drawLegend(canvas, size, textColor);
  }

  double _getYPos(double val, double chartHeight) {
    final range = yMax - yMin;
    if (range == 0) return chartHeight / 2;
    return chartHeight * (1 - (val - yMin) / range);
  }

  void _drawText(Canvas canvas, String text, Offset offset, Color color, double fontSize, TextAlign align) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize)),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout();
    tp.paint(canvas, offset);
  }

  void _drawLegend(Canvas canvas, Size size, Color textColor) {
    const legendY = 190.0;
    const startX = 16.0;
    final accentColor = const Color(0xFFFFD700);

    canvas.drawLine(Offset(startX, legendY), Offset(startX + 15, legendY), Paint()..color = accentColor..strokeWidth = 2);
    _drawText(canvas, 'Net Balance', const Offset(startX + 20, legendY - 7), textColor, 10, TextAlign.left);
  }

  List<_YLabel> _generateYLabels() {
    final range = yMax - yMin;
    if (range <= 0) {
      return [];
    }
    final step = _niceStep(range / 4);
    final labels = <_YLabel>[];
    
    double v = (yMin / step).ceil() * step;
    while (v <= yMax) {
      labels.add(_YLabel(v, _formatAmount(v)));
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
    final absV = v.abs();
    String s;
    if (absV >= 1000000) {
      s = '${(absV / 1000000).toStringAsFixed(1)}M';
    } else if (absV >= 1000) {
      s = '${(absV / 1000).toStringAsFixed(0)}K';
    } else {
      s = absV.toStringAsFixed(0);
    }
    return v < 0 ? '-$s' : s;
  }

  @override
  bool shouldRepaint(covariant _MonthlyLineGraphPainter oldDelegate) =>
      oldDelegate.cumulativeData != cumulativeData ||
      oldDelegate.yMin != yMin ||
      oldDelegate.yMax != yMax ||
      oldDelegate.isDarkMode != isDarkMode;
}

class _YLabel {
  final double value;
  final String label;
  _YLabel(this.value, this.label);
}
