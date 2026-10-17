import 'package:flutter/material.dart';

class AristonBrand extends StatelessWidget {
  const AristonBrand({
    super.key,
    this.iconSize = 36,
    this.fontSize = 24,
    this.color,
  });

  final double iconSize;
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? Theme.of(context).colorScheme.primary;

    return Semantics(
      label: 'Ariston',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: Size(iconSize, iconSize),
              painter: _AristonGlyphPainter(color: foreground),
            ),
            const SizedBox(width: 5),
            Text(
              'RISTON',
              style: TextStyle(
                color: foreground,
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: fontSize * 0.12,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AristonGlyphPainter extends CustomPainter {
  const _AristonGlyphPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 48;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.bevel;
    final glyph = Path()
      ..moveTo(8, 39)
      ..lineTo(21, 8)
      ..lineTo(37, 39)
      ..moveTo(14, 27)
      ..lineTo(31, 27);

    canvas
      ..save()
      ..scale(scale)
      ..drawPath(glyph, paint)
      ..restore();
  }

  @override
  bool shouldRepaint(_AristonGlyphPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Marca oficial em PNG: âmbar no tema escuro, roxa no claro.
class AristonLogo extends StatelessWidget {
  const AristonLogo({super.key, this.width = 220});

  final double width;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final asset = dark
        ? 'assets/brand/ariston_ambar.png'
        : 'assets/brand/ariston_roxo.png';

    // Os PNGs são quadrados com muita margem; recorta ao redor da marca.
    return Semantics(
      label: 'Ariston',
      image: true,
      child: ExcludeSemantics(
        child: ClipRect(
          child: Align(
            widthFactor: 0.58,
            heightFactor: 0.18,
            child: Image.asset(asset, width: width / 0.58),
          ),
        ),
      ),
    );
  }
}
