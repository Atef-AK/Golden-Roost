import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// A sleek, modern enterprise-grade poultry emblem designed specifically for Golden Roost.
/// Inspired by modern Scandinavian and French athletic emblems (clean geometric curves,
/// proud crest, streamlined posture, and elegant wing feather definition).
class ChickenIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final bool outlined;

  const ChickenIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? IconTheme.of(context).color ?? AppColors.primaryTeal;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _ChickenPainter(color: effectiveColor, outlined: outlined),
      ),
    );
  }
}

class _ChickenPainter extends CustomPainter {
  final Color color;
  final bool outlined;

  _ChickenPainter({required this.color, required this.outlined});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = outlined ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = outlined ? (w * 0.075).clamp(1.2, 2.4) : 0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Start at top of back / base of neck
    path.moveTo(w * 0.64, h * 0.42);

    // Rise up the back of neck
    path.cubicTo(w * 0.62, h * 0.32, w * 0.58, h * 0.22, w * 0.54, h * 0.16);

    // Sleek geometric 3-point comb (proud, streamlined crest)
    path.lineTo(w * 0.60, h * 0.08);
    path.lineTo(w * 0.52, h * 0.12);
    path.lineTo(w * 0.52, h * 0.04);
    path.lineTo(w * 0.43, h * 0.11);
    path.lineTo(w * 0.40, h * 0.07);
    path.lineTo(w * 0.34, h * 0.16);

    // Forehead down to beak base
    path.lineTo(w * 0.30, h * 0.24);

    // Sharp forward-pointing beak
    path.lineTo(w * 0.13, h * 0.30);
    path.lineTo(w * 0.28, h * 0.37);

    // Subtle wattle and throat contour
    path.quadraticBezierTo(w * 0.24, h * 0.44, w * 0.29, h * 0.47);
    path.lineTo(w * 0.33, h * 0.41);

    // Proud, athletic curved chest
    path.cubicTo(w * 0.22, h * 0.50, w * 0.20, h * 0.65, w * 0.28, h * 0.76);

    // Underbelly
    path.cubicTo(w * 0.36, h * 0.87, w * 0.50, h * 0.90, w * 0.62, h * 0.88);

    // Flank rising to tail base
    path.lineTo(w * 0.70, h * 0.82);
    path.cubicTo(w * 0.75, h * 0.77, w * 0.77, h * 0.70, w * 0.76, h * 0.62);

    // Flowing rooster sickle tail feathers arching upwards and back
    path.cubicTo(w * 0.86, h * 0.61, w * 0.95, h * 0.50, w * 0.92, h * 0.38);
    path.cubicTo(w * 0.90, h * 0.26, w * 0.86, h * 0.13, w * 0.73, h * 0.10);
    path.cubicTo(w * 0.77, h * 0.23, w * 0.74, h * 0.34, w * 0.64, h * 0.42);

    path.close();

    canvas.drawPath(path, paint);

    // Sleek aerodynamic wing accent
    final wingPath = Path();
    wingPath.moveTo(w * 0.40, h * 0.52);
    wingPath.cubicTo(
      w * 0.48,
      h * 0.67,
      w * 0.62,
      h * 0.69,
      w * 0.72,
      h * 0.58,
    );

    final wingPaint = Paint()
      ..color = outlined ? color : Colors.white.withAlpha(220)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (w * 0.07).clamp(1.0, 2.2)
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(wingPath, wingPaint);
  }

  @override
  bool shouldRepaint(covariant _ChickenPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.outlined != outlined;
  }
}
