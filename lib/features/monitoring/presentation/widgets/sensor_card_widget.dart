import 'package:flutter/material.dart';
import 'dart:math';

class SensorCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final double min;
  final double max;
  final Color color;

  const SensorCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    this.min = 0,
    this.max = 100,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    double parsedValue = double.tryParse(value) ?? 0;
    double percent = (parsedValue - min) / (max - min);
    if (percent < 0) percent = 0;
    if (percent > 1) percent = 1;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final trackColor = isDark ? Colors.grey.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.15);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, letterSpacing: 1.2),
            ),
            const Spacer(),
            Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: CustomPaint(
                  painter: _GaugePainter(percent: percent, color: color, trackColor: trackColor),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          value,
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                        ),
                        Text(
                          unit,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(min.toStringAsFixed(0), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400)),
                Text(max.toStringAsFixed(0), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percent;
  final Color color;
  final Color trackColor;

  _GaugePainter({required this.percent, required this.color, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 12.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = pi * 0.75;
    const sweepAngle = pi * 1.5;

    // Gambar background (track abu-abu gelap)
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, trackPaint);
    
    // Gambar nilai aktif (warna)
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle * percent, false, valuePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
