import 'package:captain/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PulsingSkeleton extends StatefulWidget {
  const PulsingSkeleton({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = 12,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  State<PulsingSkeleton> createState() => _PulsingSkeletonState();
}

class _PulsingSkeletonState extends State<PulsingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: Color.lerp(
              AppColors.surfaceElevated,
              AppColors.border,
              _controller.value,
            ),
          ),
        );
      },
    );
  }
}

class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 72,
  });

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < itemCount; i++) ...[
          PulsingSkeleton(height: itemHeight),
          if (i != itemCount - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}
