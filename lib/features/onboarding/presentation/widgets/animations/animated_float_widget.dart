import 'package:flutter/material.dart';

class AnimatedFloatWidget extends StatefulWidget {
  final Widget child;
  final double durationSeconds;
  final double yOffset;
  final double delaySeconds;

  const AnimatedFloatWidget({
    Key? key,
    required this.child,
    this.durationSeconds = 3.0,
    this.yOffset = -10.0,
    this.delaySeconds = 0.0,
  }) : super(key: key);

  @override
  State<AnimatedFloatWidget> createState() => _AnimatedFloatWidgetState();
}

class _AnimatedFloatWidgetState extends State<AnimatedFloatWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration:
          Duration(milliseconds: (widget.durationSeconds * 1000).toInt()),
    );
    _animation = Tween<double>(begin: 0, end: widget.yOffset).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.delaySeconds > 0) {
      Future.delayed(
        Duration(milliseconds: (widget.delaySeconds * 1000).toInt()),
        () {
          if (mounted) {
            _controller.repeat(reverse: true);
          }
        },
      );
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
