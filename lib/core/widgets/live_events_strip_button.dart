import 'package:flutter/material.dart';

import '../constants/business_category_constants.dart';

/// Events strip control: green base, slow shimmer, live ring behind icon, icon pulse, "Live" pill.
class LiveEventsStripButton extends StatefulWidget {
  const LiveEventsStripButton({
    super.key,
    required this.eventCount,
    required this.onPressed,
  });

  final int eventCount;
  final VoidCallback onPressed;

  @override
  State<LiveEventsStripButton> createState() => _LiveEventsStripButtonState();
}

class _LiveEventsStripButtonState extends State<LiveEventsStripButton>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _ringController;
  late AnimationController _iconPulseController;

  static const String _liveLabel = 'Live';

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat();

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _iconPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _ringController.dispose();
    _iconPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h = BusinessCategoryConstants.connectedButtonHeight;
    final iconSize = BusinessCategoryConstants.connectedButtonIconSize;
    final padH = BusinessCategoryConstants.connectedButtonHorizontalPadding;
    final padV = BusinessCategoryConstants.connectedButtonVerticalPadding;

    final labelStyle = theme.textTheme.labelMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      shadows: const [
        Shadow(
          color: Color.fromRGBO(0, 0, 0, 0.25),
          blurRadius: 2,
        ),
      ],
    );

    return Semantics(
      button: true,
      label: '${widget.eventCount} events, live now',
      child: Material(
        elevation: 4,
        shadowColor: Colors.green.withValues(alpha: 0.4),
        color: Colors.green.shade600,
        child: InkWell(
          onTap: widget.onPressed,
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          child: SizedBox(
            height: h,
            width: double.infinity,
            child: ClipRect(
              clipBehavior: Clip.hardEdge,
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.hardEdge,
                children: [
                  AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _ShimmerSweepPainter(progress: _shimmerController.value),
                        child: const SizedBox.expand(),
                      );
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: h - padV * 2,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _ringController,
                                builder: (context, _) {
                                  final t = _ringController.value;
                                  final scale = 1.0 + t * 0.9;
                                  final opacity = ((1.0 - t) * 0.55).clamp(0.0, 1.0);
                                  return Transform.scale(
                                    scale: scale,
                                    child: Opacity(
                                      opacity: opacity,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              ScaleTransition(
                                scale: Tween<double>(begin: 1.0, end: 1.07).animate(
                                  CurvedAnimation(
                                    parent: _iconPulseController,
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                                child: Icon(
                                  Icons.calendar_month_rounded,
                                  size: iconSize,
                                  color: Colors.white,
                                  shadows: const [
                                    Shadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.35),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${widget.eventCount} Events',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: labelStyle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            child: Text(
                              _liveLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                height: 1.1,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerSweepPainter extends CustomPainter {
  _ShimmerSweepPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // Narrow band, low contrast — stays inside button bounds (parent clips).
    final bandW = size.width * 0.28;
    final travel = size.width + bandW;
    // Start with band fully off the left edge so the sweep does not begin on the seam.
    final left = -bandW + travel * progress;
    final rect = Rect.fromLTWH(left, 0, bandW, size.height);
    final shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.white.withValues(alpha: 0),
        Colors.white.withValues(alpha: 0.085),
        Colors.white.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(rect);
    final paint = Paint()..shader = shader;
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _ShimmerSweepPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
