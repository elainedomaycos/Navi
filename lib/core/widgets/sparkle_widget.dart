import 'package:flutter/material.dart';

class SparkleWidget extends StatelessWidget {
  final Color color;
  final double size;

  const SparkleWidget({
    super.key,
    required this.color,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SparklePainter(color: color),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final Color color;
  const _SparklePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final path = Path();
    path.moveTo(cx, cy - r);
    path.quadraticBezierTo(cx + r * 0.15, cy - r * 0.15, cx + r, cy);
    path.quadraticBezierTo(cx + r * 0.15, cy + r * 0.15, cx, cy + r);
    path.quadraticBezierTo(cx - r * 0.15, cy + r * 0.15, cx - r, cy);
    path.quadraticBezierTo(cx - r * 0.15, cy - r * 0.15, cx, cy - r);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.color != color;
}
