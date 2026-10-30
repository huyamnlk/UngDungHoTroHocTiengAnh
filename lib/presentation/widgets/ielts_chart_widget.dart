import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class IeltsChartWidget extends StatelessWidget {
  final String title;
  final String chartType; // 'bar', 'line', 'table'
  final Map<String, dynamic> data;

  const IeltsChartWidget({
    super.key,
    required this.title,
    required this.chartType,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                chartType == 'line'
                    ? Icons.show_chart_rounded
                    : (chartType == 'table' ? Icons.table_chart_rounded : Icons.bar_chart_rounded),
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (chartType == 'bar')
            SizedBox(
              height: 220,
              child: CustomPaint(
                painter: _IeltsBarChartPainter(data: data, isDark: isDark),
              ),
            )
          else if (chartType == 'line')
            SizedBox(
              height: 220,
              child: CustomPaint(
                painter: _IeltsLineChartPainter(data: data, isDark: isDark),
              ),
            )
          else
            _buildTable(context, isDark),
          const SizedBox(height: 12),
          _buildLegend(context, isDark),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, bool isDark) {
    final headers = (data['headers'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final rows = (data['rows'] as List<dynamic>?) ?? [];

    return Table(
      border: TableBorder.all(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(8),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          ),
          children: headers.map((h) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                h,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
        ),
        ...rows.map((row) {
          final cells = (row as List<dynamic>).map((e) => e.toString()).toList();
          return TableRow(
            children: cells.map((c) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Text(
                  c,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildLegend(BuildContext context, bool isDark) {
    final series = (data['series'] as List<dynamic>?) ?? [];
    if (series.isEmpty) return const SizedBox.shrink();

    final colors = [
      AppColors.primary,
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: series.asMap().entries.map((entry) {
        final idx = entry.key;
        final name = (entry.value as Map<String, dynamic>)['name'] ?? 'Series ${idx + 1}';
        final color = colors[idx % colors.length];

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              name.toString(),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _IeltsBarChartPainter extends CustomPainter {
  final Map<String, dynamic> data;
  final bool isDark;

  _IeltsBarChartPainter({required this.data, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final categories = (data['categories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final series = (data['series'] as List<dynamic>?) ?? [];
    if (categories.isEmpty || series.isEmpty) return;

    const paddingLeft = 40.0;
    const paddingBottom = 30.0;
    const paddingTop = 15.0;
    const paddingRight = 15.0;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;

    // Tìm maxValue
    double maxVal = 10.0;
    for (final s in series) {
      final values = (s['values'] as List<dynamic>?) ?? [];
      for (final v in values) {
        final d = (v as num).toDouble();
        if (d > maxVal) maxVal = d;
      }
    }
    maxVal = (maxVal * 1.15).ceilToDouble();

    final gridPaint = Paint()
      ..color = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    final textStyle = TextStyle(
      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      fontSize: 10,
    );

    // Vẽ đường ngang & nhãn Y
    const steps = 4;
    for (int i = 0; i <= steps; i++) {
      final yVal = (maxVal / steps) * i;
      final yPos = paddingTop + chartHeight - (chartHeight / steps) * i;
      canvas.drawLine(Offset(paddingLeft, yPos), Offset(size.width - paddingRight, yPos), gridPaint);

      final textSpan = TextSpan(text: '${yVal.round()}%', style: textStyle);
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(paddingLeft - tp.width - 6, yPos - tp.height / 2));
    }

    // Vẽ các cột nhóm
    final seriesColors = [
      AppColors.primary,
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
    ];

    final groupWidth = chartWidth / categories.length;
    final numSeries = series.length;
    final barWidth = (groupWidth * 0.6) / numSeries;

    for (int c = 0; c < categories.length; c++) {
      final groupX = paddingLeft + c * groupWidth;

      // Nhãn danh mục X
      final catSpan = TextSpan(text: categories[c], style: textStyle.copyWith(fontWeight: FontWeight.bold));
      final catTp = TextPainter(text: catSpan, textDirection: TextDirection.ltr);
      catTp.layout(maxWidth: groupWidth);
      catTp.paint(canvas, Offset(groupX + (groupWidth - catTp.width) / 2, paddingTop + chartHeight + 6));

      // Các thanh
      for (int s = 0; s < numSeries; s++) {
        final values = (series[s]['values'] as List<dynamic>?) ?? [];
        final val = c < values.length ? (values[c] as num).toDouble() : 0.0;
        final barHeight = (val / maxVal) * chartHeight;

        final barX = groupX + (groupWidth * 0.2) + s * barWidth;
        final barY = paddingTop + chartHeight - barHeight;

        final barPaint = Paint()
          ..color = seriesColors[s % seriesColors.length]
          ..style = PaintingStyle.fill;

        final rrect = RRect.fromRectAndCorners(
          Rect.fromLTWH(barX, barY, barWidth * 0.88, barHeight),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        );
        canvas.drawRRect(rrect, barPaint);

        // Hiển thị giá trị trên đỉnh cột
        if (barHeight > 18) {
          final valSpan = TextSpan(
            text: '${val.round()}',
            style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
          );
          final valTp = TextPainter(text: valSpan, textDirection: TextDirection.ltr);
          valTp.layout();
          valTp.paint(canvas, Offset(barX + (barWidth * 0.88 - valTp.width) / 2, barY + 3));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IeltsBarChartPainter oldDelegate) => true;
}

class _IeltsLineChartPainter extends CustomPainter {
  final Map<String, dynamic> data;
  final bool isDark;

  _IeltsLineChartPainter({required this.data, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final categories = (data['categories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final series = (data['series'] as List<dynamic>?) ?? [];
    if (categories.isEmpty || series.isEmpty) return;

    const paddingLeft = 40.0;
    const paddingBottom = 30.0;
    const paddingTop = 15.0;
    const paddingRight = 15.0;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;

    double maxVal = 10.0;
    for (final s in series) {
      final values = (s['values'] as List<dynamic>?) ?? [];
      for (final v in values) {
        final d = (v as num).toDouble();
        if (d > maxVal) maxVal = d;
      }
    }
    maxVal = (maxVal * 1.15).ceilToDouble();

    final gridPaint = Paint()
      ..color = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    final textStyle = TextStyle(
      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      fontSize: 10,
    );

    const steps = 4;
    for (int i = 0; i <= steps; i++) {
      final yVal = (maxVal / steps) * i;
      final yPos = paddingTop + chartHeight - (chartHeight / steps) * i;
      canvas.drawLine(Offset(paddingLeft, yPos), Offset(size.width - paddingRight, yPos), gridPaint);

      final textSpan = TextSpan(text: '${yVal.round()}', style: textStyle);
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(paddingLeft - tp.width - 6, yPos - tp.height / 2));
    }

    final seriesColors = [
      AppColors.primary,
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
    ];

    final xStep = chartWidth / (categories.length - 1).clamp(1, 99);

    for (int c = 0; c < categories.length; c++) {
      final xPos = paddingLeft + c * xStep;
      final catSpan = TextSpan(text: categories[c], style: textStyle);
      final catTp = TextPainter(text: catSpan, textDirection: TextDirection.ltr);
      catTp.layout();
      catTp.paint(canvas, Offset(xPos - catTp.width / 2, paddingTop + chartHeight + 6));
    }

    for (int s = 0; s < series.length; s++) {
      final values = (series[s]['values'] as List<dynamic>?) ?? [];
      final color = seriesColors[s % seriesColors.length];
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final pointPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final path = Path();
      for (int c = 0; c < values.length && c < categories.length; c++) {
        final val = (values[c] as num).toDouble();
        final xPos = paddingLeft + c * xStep;
        final yPos = paddingTop + chartHeight - (val / maxVal) * chartHeight;

        if (c == 0) {
          path.moveTo(xPos, yPos);
        } else {
          path.lineTo(xPos, yPos);
        }
        canvas.drawCircle(Offset(xPos, yPos), 4.0, pointPaint);
      }
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _IeltsLineChartPainter oldDelegate) => true;
}
