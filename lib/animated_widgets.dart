import 'package:flutter/material.dart';

class AdvancedPageTransition extends PageRouteBuilder {
  final Widget page;

  AdvancedPageTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 0.05), // Slight slide up
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutQuart,
              ),
            );

            var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutQuart,
              ),
            );

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );
}

class ElasticBouncingWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleFactor;

  const ElasticBouncingWidget({
    Key? key,
    required this.child,
    required this.onTap,
    this.scaleFactor = 0.92,
  }) : super(key: key);

  @override
  _ElasticBouncingWidgetState createState() => _ElasticBouncingWidgetState();
}

class _ElasticBouncingWidgetState extends State<ElasticBouncingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic, // Fast down
        reverseCurve: Curves.elasticOut, // Elastic bounce back
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

class StaggeredEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const StaggeredEntrance({Key? key, required this.child, required this.delay})
      : super(key: key);

  @override
  _StaggeredEntranceState createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

class AnimatedMark extends StatelessWidget {
  final String mark;
  final Color playerXColor;
  final Color playerOColor;

  const AnimatedMark({
    Key? key,
    required this.mark,
    required this.playerXColor,
    required this.playerOColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.elasticOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: animation,
          child: RotationTransition(
            turns: Tween<double>(begin: -0.05, end: 0).animate(animation),
            child: child,
          ),
        );
      },
      child: mark == ''
          ? const SizedBox.shrink()
          : Text(
              mark,
              key: ValueKey<String>(mark),
              style: TextStyle(
                fontSize: 55,
                fontWeight: FontWeight.w800,
                color: mark == 'X' ? playerXColor : playerOColor,
              ),
            ),
    );
  }
}

class PulsingText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const PulsingText({Key? key, required this.text, required this.style})
      : super(key: key);

  @override
  _PulsingTextState createState() => _PulsingTextState();
}

class _PulsingTextState extends State<PulsingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.6 + (_controller.value * 0.4), // Pulse between 0.6 and 1.0
          child: Text(
            widget.text,
            style: widget.style,
          ),
        );
      },
    );
  }
}
