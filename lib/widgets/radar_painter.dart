import 'dart:math';
import 'package:flutter/material.dart';
import '../models/friend.dart';
import '../models/pin.dart';

class RadarPainter extends CustomPainter {
  final Friend? me;
  final List<Friend> friends;
  final List<Pin> pins;
  final double sweepAngle;
  final double radarRange;
  final bool showNames;
  final double heading;

  RadarPainter({
    required this.me,
    required this.friends,
    required this.pins,
    required this.sweepAngle,
    required this.radarRange,
    required this.showNames,
    required this.heading,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    _drawBackground(canvas, center, radius);
    _drawGrid(canvas, center, radius);
    _drawSweep(canvas, center, radius);
    _drawPins(canvas, center, radius);
    _drawFriends(canvas, center, radius);
    _drawSelf(canvas, center, radius);
  }

  void _drawBackground(Canvas canvas, Offset center, double radius) {
    final bgPaint = Paint()..color = const Color(0xFF050510);
    canvas.drawCircle(center, radius, bgPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF00aaff)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, borderPaint);
  }

  void _drawGrid(Canvas canvas, Offset center, double radius) {
    final gridPaint = Paint()
      ..color = const Color(0xFF00aaff).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * i / 4, gridPaint);
    }

    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        ),
        gridPaint,
      );
    }

    _drawCompassLabels(canvas, center, radius);
  }

  void _drawCompassLabels(Canvas canvas, Offset center, double radius) {
    final labels = ['N', 'NE', 'E', 'SE', 'S', 'SO', 'O', 'NO'];
    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4 - pi / 2;
      final labelRadius = radius * 0.88;
      final pos = Offset(
        center.dx + labelRadius * cos(angle),
        center.dy + labelRadius * sin(angle),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: Color(0xFF00aaff),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2),
      );
    }
  }

  void _drawSweep(Canvas canvas, Offset center, double radius) {
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: sweepAngle - pi / 6,
        endAngle: sweepAngle,
        colors: [
          Colors.transparent,
          const Color(0xFF00aaff).withOpacity(0.4),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      sweepAngle - pi / 6,
      pi / 6,
      true,
      sweepPaint,
    );

    final linePaint = Paint()
      ..color = const Color(0xFF00aaff).withOpacity(0.8)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * cos(sweepAngle),
        center.dy + radius * sin(sweepAngle),
      ),
      linePaint,
    );
  }

  void _drawFriends(Canvas canvas, Offset center, double radius) {
    if (me == null) return;
    final now = DateTime.now();

    for (final friend in friends) {
      final age = now.difference(friend.lastSeen).inSeconds;
      final opacity = age > 30 ? 0.3 : 1.0 - (age / 30) * 0.5;

      final dist = _distanceBetween(me!.lat, me!.lon, friend.lat, friend.lon);
      if (dist > radarRange) continue;

      final bearing =
          _bearingBetween(me!.lat, me!.lon, friend.lat, friend.lon);
      final relAngle = bearing - heading - pi / 2;
      final r = (dist / radarRange) * radius * 0.85;
      final pos = Offset(
        center.dx + r * cos(relAngle),
        center.dy + r * sin(relAngle),
      );

      final color = _hexToColor(friend.color).withOpacity(opacity);
      _drawShape(canvas, pos, 8, friend.shape, color);

      if (showNames) {
        _drawLabel(canvas, pos, friend.name, color);
      }
    }
  }

  void _drawSelf(Canvas canvas, Offset center, double radius) {
    final selfColor = me != null
        ? _hexToColor(me!.color)
        : const Color(0xFF00aaff);
    final selfShape = me?.shape ?? 'circle';

    _drawShape(canvas, center, 10, selfShape, selfColor);

    final dirPaint = Paint()
      ..color = selfColor
      ..strokeWidth = 2;
    canvas.drawLine(
      center,
      Offset(
        center.dx + 18 * cos(-heading - pi / 2),
        center.dy + 18 * sin(-heading - pi / 2),
      ),
      dirPaint,
    );
  }

  void _drawPins(Canvas canvas, Offset center, double radius) {
    if (me == null) return;
    for (final pin in pins) {
      final dist = _distanceBetween(me!.lat, me!.lon, pin.lat, pin.lon);
      if (dist > radarRange) continue;

      final bearing = _bearingBetween(me!.lat, me!.lon, pin.lat, pin.lon);
      final relAngle = bearing - heading - pi / 2;
      final r = (dist / radarRange) * radius * 0.85;
      final pos = Offset(
        center.dx + r * cos(relAngle),
        center.dy + r * sin(relAngle),
      );

      final color = _hexToColor(pin.color);
      _drawPinMarker(canvas, pos, color);
      if (showNames && pin.name.isNotEmpty) {
        _drawLabel(canvas, pos + const Offset(0, -14), pin.name, color);
      }
    }
  }

  void _drawShape(
      Canvas canvas, Offset pos, double size, String shape, Color color) {
    final paint = Paint()..color = color;
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    switch (shape) {
      case 'square':
        final rect =
            Rect.fromCenter(center: pos, width: size * 2, height: size * 2);
        canvas.drawRect(rect, paint);
        canvas.drawRect(rect, borderPaint);
        break;
      case 'triangle':
        final path = Path()
          ..moveTo(pos.dx, pos.dy - size)
          ..lineTo(pos.dx + size, pos.dy + size)
          ..lineTo(pos.dx - size, pos.dy + size)
          ..close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);
        break;
      case 'star':
        final path = _starPath(pos, size, 5);
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);
        break;
      case 'diamond':
        final path = Path()
          ..moveTo(pos.dx, pos.dy - size)
          ..lineTo(pos.dx + size, pos.dy)
          ..lineTo(pos.dx, pos.dy + size)
          ..lineTo(pos.dx - size, pos.dy)
          ..close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);
        break;
      default:
        canvas.drawCircle(pos, size, paint);
        canvas.drawCircle(pos, size, borderPaint);
    }
  }

  Path _starPath(Offset center, double outerR, int points) {
    final innerR = outerR * 0.4;
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = i * pi / points - pi / 2;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    return path..close();
  }

  void _drawPinMarker(Canvas canvas, Offset pos, Color color) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(pos.dx, pos.dy - 10)
      ..lineTo(pos.dx + 5, pos.dy - 3)
      ..lineTo(pos.dx, pos.dy)
      ..lineTo(pos.dx - 5, pos.dy - 3)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawLabel(
      Canvas canvas, Offset pos, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        canvas,
        Offset(
          pos.dx - tp.width / 2,
          pos.dy + 12,
        ));
  }

  double _distanceBetween(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _bearingBetween(
      double lat1, double lon1, double lat2, double lon2) {
    final dLon = (lon2 - lon1) * pi / 180;
    final y = sin(dLon) * cos(lat2 * pi / 180);
    final x = cos(lat1 * pi / 180) * sin(lat2 * pi / 180) -
        sin(lat1 * pi / 180) * cos(lat2 * pi / 180) * cos(dLon);
    return atan2(y, x);
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) =>
      oldDelegate.sweepAngle != sweepAngle ||
      oldDelegate.friends != friends ||
      oldDelegate.me != me ||
      oldDelegate.pins != pins;
}
