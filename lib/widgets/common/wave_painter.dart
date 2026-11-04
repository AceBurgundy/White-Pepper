import 'dart:math' as math;
import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  const WavePainter({
    required this.waveColor,
    this.amplitude = 6.0,
    this.frequency = 0.03,
    this.strokeWidth = 2.0,
  });

  final Color waveColor;
  final double amplitude;
  final double frequency;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Path path = Path();
    final double midY = size.height / 2;

    path.moveTo(0, midY);
    for (double x = 0; x <= size.width; x += 1.0) {
      final double y = midY + math.sin(x * frequency) * amplitude;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.waveColor != waveColor ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.frequency != frequency ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
