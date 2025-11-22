import 'package:flutter/material.dart';

class Skeleton extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  const Skeleton({super.key, required this.width, required this.height, this.borderRadius});

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.black12;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final shimmer = LinearGradient(
          colors: [base, base.withOpacity(0.04), base],
          stops: [(_controller.value - 0.2).clamp(0.0, 1.0), _controller.value, (_controller.value + 0.2).clamp(0.0, 1.0)],
          begin: const Alignment(-1, -0.3),
          end: const Alignment(1, 0.3),
        );
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: base,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          ),
          child: ShaderMask(
            shaderCallback: (rect) => shimmer.createShader(rect),
            blendMode: BlendMode.srcATop,
            child: Container(color: Colors.white.withOpacity(0.0)),
          ),
        );
      },
    );
  }
}
