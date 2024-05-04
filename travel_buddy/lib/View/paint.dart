import 'dart:ui';
import 'package:flutter/material.dart';

class MyPainter extends CustomPainter {
  List<Offset?> points;

  MyPainter(this.points);

  @override
      void paint(Canvas canvas, Size size) {
        var paint = Paint()
          ..color = Colors.white
          ..strokeCap = StrokeCap.square
          ..strokeWidth = 5.0;

        for (int i = 0; i < points.length - 1; i++) {
          if (points[i] != null && points[i + 1] != null) {
            canvas.drawLine(points[i]!, points[i + 1]!, paint);
          }
        }
      }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
