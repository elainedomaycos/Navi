import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class RadarChartWidget extends pw.StatelessWidget {
  final Map<String, double> data;
  final List<String> labels;
  final double size;

  RadarChartWidget({
    required this.data,
    required this.labels,
    this.size = 220,
  });

  @override
  pw.Widget build(pw.Context context) {
    return pw.CustomPaint(
      size: PdfPoint(size, size),
      painter: (PdfGraphics canvas, PdfPoint sz) {
        _paint(canvas, sz);
      },
    );
  }

  void _paint(PdfGraphics canvas, PdfPoint sz) {
    final cx = sz.x / 2;
    final cy = sz.y / 2;
    final radius = (cx < cy ? cx : cy) - 30;
    final n = labels.length;
    const pi = 3.14159265;
    final angleStep = 2 * pi / n;
    final startAngle = -pi / 2;

    const gridColor = PdfColor(0.88, 0.86, 0.96);
    const primary = PdfColor(0.24, 0.21, 0.50);

    // Grid pentagons
    final levels = [0.2, 0.4, 0.6, 0.8, 1.0];
    for (final level in levels) {
      final r = radius * level;
      canvas.saveContext();
      canvas.setStrokeColor(gridColor);
      canvas.setLineWidth(0.5);
      for (var i = 0; i <= n; i++) {
        final idx = i % n;
        final angle = startAngle + idx * angleStep;
        final x = cx + r * _cos(angle);
        final y = cy + r * _sin(angle);
        if (i == 0) {
          canvas.moveTo(x, y);
        } else {
          canvas.lineTo(x, y);
        }
      }
      canvas.closePath();
      canvas.strokePath();
      canvas.restoreContext();
    }

    // Axis lines
    canvas.saveContext();
    canvas.setStrokeColor(gridColor);
    canvas.setLineWidth(0.4);
    for (var i = 0; i < n; i++) {
      final angle = startAngle + i * angleStep;
      final x = cx + radius * _cos(angle);
      final y = cy + radius * _sin(angle);
      canvas.moveTo(cx, cy);
      canvas.lineTo(x, y);
      canvas.strokePath();
    }
    canvas.restoreContext();

    // Data polygon
    final values = labels.map((l) => data[l] ?? 0.3).toList();
    canvas.saveContext();
    canvas.setFillColor(
      PdfColor(primary.red, primary.green, primary.blue, 0.3),
    );
    canvas.setStrokeColor(primary);
    canvas.setLineWidth(1.5);
    for (var i = 0; i <= n; i++) {
      final idx = i % n;
      final angle = startAngle + idx * angleStep;
      final r = radius * values[idx];
      final x = cx + r * _cos(angle);
      final y = cy + r * _sin(angle);
      if (i == 0) {
        canvas.moveTo(x, y);
      } else {
        canvas.lineTo(x, y);
      }
    }
    canvas.closePath();
    canvas.fillAndStrokePath(close: true);

    // Data points
    for (var i = 0; i < n; i++) {
      final angle = startAngle + i * angleStep;
      final r = radius * values[i];
      final x = cx + r * _cos(angle);
      final y = cy + r * _sin(angle);
      canvas.setFillColor(PdfColors.white);
      canvas.setStrokeColor(primary);
      canvas.setLineWidth(1.2);
      canvas.drawEllipse(x, y, 3, 3);
      canvas.fillAndStrokePath(close: true);
    }
    canvas.restoreContext();
  }

  static double _cos(double a) {
    final pi = 3.14159265;
    var x = a % (2 * pi);
    if (x < 0) x += 2 * pi;
    if (x < pi / 2) {
      return 1 - x * x / 2 + x * x * x * x / 24;
    } else if (x < pi) {
      return -_cos(pi - x);
    } else if (x < 3 * pi / 2) {
      return -_cos(x - pi);
    } else {
      return _cos(2 * pi - x);
    }
  }

  static double _sin(double a) {
    final pi = 3.14159265;
    return _cos(a - pi / 2);
  }
}
