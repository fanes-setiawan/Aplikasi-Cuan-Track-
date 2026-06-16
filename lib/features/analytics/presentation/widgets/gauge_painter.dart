import 'dart:math';
import 'package:flutter/material.dart';

class GaugePainter extends CustomPainter {
  final double score; // Nilai 0 - 100
  final Color needleColor;

  GaugePainter({
    required this.score,
    this.needleColor = const Color(0xFF212121),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.12;

    // 1. Gambar Background Arc Segmen
    final Rect rect = Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2));
    
    // Segmen Merah (Bahaya: 0 - 35%)
    final Paint paintRed = Paint()
      ..color = const Color(0xFFFFCDD2) // Soft red background
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Paint paintRedActive = Paint()
      ..color = const Color(0xFFE53935) // Red active
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Segmen Kuning (Waspada: 35 - 70%)
    final Paint paintYellow = Paint()
      ..color = const Color(0xFFFFF9C4) // Soft yellow background
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Paint paintYellowActive = Paint()
      ..color = const Color(0xFFFDD835) // Yellow active
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Segmen Hijau (Sehat: 70 - 100%)
    final Paint paintGreen = Paint()
      ..color = const Color(0xFFC8E6C9) // Soft green background
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Paint paintGreenActive = Paint()
      ..color = const Color(0xFF4CAF50) // Green active
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Hitung sudut-sudut segmen dalam radian
    // Total sudut setengah lingkaran adalah pi radian (180 derajat)
    const startAngle = pi;
    const sweepRed = pi * 0.35;
    const sweepYellow = pi * 0.35;
    const sweepGreen = pi * 0.30;

    // Render Background Arc (jika pasif)
    canvas.drawArc(rect, startAngle, sweepRed, false, paintRed);
    canvas.drawArc(rect, startAngle + sweepRed, sweepYellow, false, paintYellow);
    canvas.drawArc(rect, startAngle + sweepRed + sweepYellow, sweepGreen, false, paintGreen);

    // Render Active Arc berdasarkan nilai score saat ini
    final currentSweep = (score / 100.0) * pi;
    
    if (score > 0) {
      if (score <= 35) {
        canvas.drawArc(rect, startAngle, currentSweep, false, paintRedActive);
      } else if (score <= 70) {
        canvas.drawArc(rect, startAngle, sweepRed, false, paintRedActive);
        canvas.drawArc(rect, startAngle + sweepRed, currentSweep - sweepRed, false, paintYellowActive);
      } else {
        canvas.drawArc(rect, startAngle, sweepRed, false, paintRedActive);
        canvas.drawArc(rect, startAngle + sweepRed, sweepYellow, false, paintYellowActive);
        canvas.drawArc(rect, startAngle + sweepRed + sweepYellow, currentSweep - sweepRed - sweepYellow, false, paintGreenActive);
      }
    }

    // 2. Gambar Jarum Penunjuk (Needle)
    final needlePaint = Paint()
      ..color = needleColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Hitung sudut jarum (score dari 0-100 dipetakan ke pi hingga 2*pi)
    final needleAngle = pi + (score / 100.0) * pi;
    final needleLength = radius * 0.85;

    // Ujung jarum
    final needleTip = Offset(
      center.dx + needleLength * cos(needleAngle),
      center.dy + needleLength * sin(needleAngle),
    );

    // Alas jarum (segitiga ramping dari lingkaran tengah)
    final baseAngleLeft = needleAngle - (pi / 2) + 0.05;
    final baseAngleRight = needleAngle + (pi / 2) - 0.05;
    final baseRadius = size.width * 0.04;

    final baseLeft = Offset(
      center.dx + baseRadius * cos(baseAngleLeft),
      center.dy + baseRadius * sin(baseAngleLeft),
    );
    final baseRight = Offset(
      center.dx + baseRadius * cos(baseAngleRight),
      center.dy + baseRadius * sin(baseAngleRight),
    );

    final Path needlePath = Path()
      ..moveTo(needleTip.dx, needleTip.dy)
      ..lineTo(baseLeft.dx, baseLeft.dy)
      ..lineTo(baseRight.dx, baseRight.dy)
      ..close();

    canvas.drawPath(needlePath, needlePaint);

    // 3. Gambar Lingkaran Pusat Jarum (Center Cap)
    final centerCapPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final centerBorderPaint = Paint()
      ..color = needleColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, baseRadius, centerCapPaint);
    canvas.drawCircle(center, baseRadius, centerBorderPaint);
    canvas.drawCircle(center, baseRadius * 0.4, needlePaint);
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.needleColor != needleColor;
  }
}
