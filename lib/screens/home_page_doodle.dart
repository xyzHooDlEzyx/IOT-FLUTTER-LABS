part of 'home_page.dart';

class _DoodleOverlay extends StatefulWidget {
  const _DoodleOverlay({
    required this.color,
    required this.onFinished,
  });

  final Color color;
  final VoidCallback onFinished;

  @override
  State<_DoodleOverlay> createState() => _DoodleOverlayState();
}

class _DoodleOverlayState extends State<_DoodleOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final int _seed;

  @override
  void initState() {
    super.initState();
    _seed = DateTime.now().millisecondsSinceEpoch;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward().whenComplete(widget.onFinished);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final fadeIn = CurvedAnimation(
              parent: _controller,
              curve: const Interval(0, 0.2, curve: Curves.easeOut),
            ).value;
            final fadeOut = CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.6, 1, curve: Curves.easeIn),
            ).value;
            final opacity = fadeIn * (1 - fadeOut);
            final scale = lerpDouble(0.9, 1, fadeIn) ?? 1;

            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: CustomPaint(
                  painter: _DoodlePainter(
                    seed: _seed,
                    color: widget.color,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DoodlePainter extends CustomPainter {
  _DoodlePainter({
    required this.seed,
    required this.color,
  });

  final int seed;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final start = Offset(
      size.width * (0.2 + random.nextDouble() * 0.6),
      size.height * (0.2 + random.nextDouble() * 0.6),
    );
    path.moveTo(start.dx, start.dy);

    for (var i = 0; i < 18; i++) {
      final dx = (random.nextDouble() - 0.5) * 140;
      final dy = (random.nextDouble() - 0.5) * 140;
      final next = Offset(
        (path.getBounds().center.dx + dx).clamp(24, size.width - 24),
        (path.getBounds().center.dy + dy).clamp(24, size.height - 24),
      );
      path.quadraticBezierTo(
        next.dx + (random.nextDouble() - 0.5) * 40,
        next.dy + (random.nextDouble() - 0.5) * 40,
        next.dx,
        next.dy,
      );
    }

    canvas.drawPath(path, paint);

    final accentPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path.shift(const Offset(8, -8)), accentPaint);
  }

  @override
  bool shouldRepaint(covariant _DoodlePainter oldDelegate) {
    return oldDelegate.seed != seed || oldDelegate.color != color;
  }
}
