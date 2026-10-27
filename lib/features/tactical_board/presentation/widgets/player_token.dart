import 'dart:math' as math;

import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/core/theme/arabic_text_styles.dart';
import 'package:captain/features/tactical_board/domain/player.dart';
import 'package:flutter/material.dart';

/// Kit-style player marker: shaded shirt disc with number, team ring,
/// ground shadow and a short "running" bob while moving.
class PlayerToken extends StatefulWidget {
  const PlayerToken({
    super.key,
    required this.player,
    required this.size,
    this.showLabel = true,
    this.isSelected = false,
    this.isDragging = false,
    this.isRunning = false,
    this.elevatedShadow = false,
    this.homeColor,
    this.awayColor,
  });

  final Player player;
  final double size;
  final bool showLabel;
  final bool isSelected;
  final bool isDragging;
  final bool isRunning;
  final bool elevatedShadow;
  final Color? homeColor;
  final Color? awayColor;

  @override
  State<PlayerToken> createState() => _PlayerTokenState();
}

class _PlayerTokenState extends State<PlayerToken>
    with SingleTickerProviderStateMixin {
  AnimationController? _run;

  @override
  void initState() {
    super.initState();
    _syncRun();
  }

  @override
  void didUpdateWidget(covariant PlayerToken oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncRun();
  }

  void _syncRun() {
    if (widget.isRunning) {
      _run ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 320),
      );
      if (!_run!.isAnimating) _run!.repeat();
    } else {
      _run?.stop();
    }
  }

  @override
  void dispose() {
    _run?.dispose();
    super.dispose();
  }

  Color get _kit {
    final p = widget.player;
    if (p.isHomeTeam) return widget.homeColor ?? AppColors.homeTeam;
    return widget.awayColor ?? AppColors.awayTeam;
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final lifted = widget.isDragging || widget.elevatedShadow;
    final isGk = (widget.player.label ?? '').toUpperCase() == 'GK';
    final kit = isGk ? const Color(0xFFF59E0B) : _kit;
    final darker = Color.lerp(kit, Colors.black, 0.45)!;
    final lighter = Color.lerp(kit, Colors.white, 0.35)!;

    Widget disc = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 1.0,
          colors: [lighter, kit, darker],
          stops: const [0.0, 0.55, 1.0],
        ),
        border: Border.all(
          color: widget.isSelected ? AppColors.accentOrange : Colors.white,
          width: widget.isSelected ? size * 0.075 : size * 0.055,
        ),
        boxShadow: [
          if (widget.isSelected)
            BoxShadow(
              color: AppColors.accentOrange.withValues(alpha: 0.7),
              blurRadius: size * 0.5,
              spreadRadius: size * 0.03,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: lifted ? 0.55 : 0.4),
            blurRadius: size * (lifted ? 0.35 : 0.14),
            offset: Offset(0, size * (lifted ? 0.18 : 0.07)),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Collar / shirt stripe for a kit look.
          Positioned(
            top: size * 0.08,
            child: Container(
              width: size * 0.34,
              height: size * 0.1,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(size * 0.1),
                ),
              ),
            ),
          ),
          Text(
            '${widget.player.number}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: size * 0.4,
              height: 1.1,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 3)],
            ),
          ),
        ],
      ),
    );

    final run = _run;
    if (run != null && widget.isRunning) {
      disc = AnimatedBuilder(
        animation: run,
        builder: (context, child) {
          final bob = math.sin(run.value * 2 * math.pi).abs();
          return Transform.translate(
            offset: Offset(0, -bob * size * 0.08),
            child: child,
          );
        },
        child: disc,
      );
    }

    return AnimatedScale(
      scale: lifted ? 1.18 : 1.0,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutBack,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          disc,
          if (widget.showLabel &&
              widget.player.label != null &&
              widget.player.label!.isNotEmpty) ...[
            SizedBox(height: size * 0.06),
            Container(
              constraints: BoxConstraints(maxWidth: size * 2.4),
              padding: EdgeInsets.symmetric(
                horizontal: size * 0.12,
                vertical: size * 0.01,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(size),
              ),
              child: Text(
                ellipsizeLabel(widget.player.label!),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: ArabicTextStyles.cairo(
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
