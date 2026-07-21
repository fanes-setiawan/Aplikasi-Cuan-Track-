import 'package:flutter/material.dart';

class AnimatedPulseGlowWidget extends StatefulWidget {
  final Widget child;
  final double durationSeconds;
  final double minOpacity;
  final double maxOpacity;
  final double minScale;
  final double maxScale;

  const AnimatedPulseGlowWidget({
    Key? key,
    required this.child,
    this.durationSeconds = 2.0,
    this.minOpacity = 0.4,
    this.maxOpacity = 0.8,
    this.minScale = 1.0,
    this.maxScale = 1.05,
  }) : super(key: key);

  @override
  State<AnimatedPulseGlowWidget> createState() =>
      _AnimatedPulseGlowWidgetState();
}

class _AnimatedPulseGlowWidgetState extends State<AnimatedPulseGlowWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration:
          Duration(milliseconds: (widget.durationSeconds * 1000).toInt()),
    );
    _scaleAnimation = Tween<double>(
            begin: widget.minScale, end: widget.maxScale)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _opacityAnimation = Tween<double>(
            begin: widget.minOpacity, end: widget.maxOpacity)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);
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
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
