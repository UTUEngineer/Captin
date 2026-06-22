import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/tactical_board/domain/player.dart';
import 'package:captain/features/tactical_board/presentation/widgets/player_token.dart';
import 'package:flutter/material.dart';

class SpotlightPlayerToken extends StatefulWidget {
  const SpotlightPlayerToken({
    super.key,
    required this.player,
    required this.size,
  });

  final Player player;
  final double size;

  @override
  State<SpotlightPlayerToken> createState() => _SpotlightPlayerTokenState();
}

class _SpotlightPlayerTokenState extends State<SpotlightPlayerToken>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulse.value,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentOrange.withValues(alpha: 0.85),
                  blurRadius: widget.size * 0.7,
                  spreadRadius: widget.size * 0.08,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: PlayerToken(
        player: widget.player,
        size: widget.size,
        isSelected: true,
      ),
    );
  }
}
