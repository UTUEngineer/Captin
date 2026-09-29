import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Retro Scoreboard 4-Digit Captain PIN Numpad Component
class CaptainPinPadWidget extends StatefulWidget {
  final ValueChanged<String> onPinComplete;
  final bool loading;
  final String? pinError;

  const CaptainPinPadWidget({
    super.key,
    required this.onPinComplete,
    this.loading = false,
    this.pinError,
  });

  @override
  State<CaptainPinPadWidget> createState() => _CaptainPinPadWidgetState();
}

class _CaptainPinPadWidgetState extends State<CaptainPinPadWidget> with SingleTickerProviderStateMixin {
  final List<String> _digits = [];
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant CaptainPinPadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pinError != null && oldWidget.pinError != widget.pinError) {
      _shakeController.forward(from: 0.0);
      _digits.clear();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _handlePress(String num) {
    if (_digits.length >= 4 || widget.loading) return;
    HapticFeedback.lightImpact();

    setState(() {
      _digits.add(num);
    });

    if (_digits.length == 4) {
      widget.onPinComplete(_digits.join(''));
    }
  }

  void _handleDelete() {
    if (_digits.isEmpty || widget.loading) return;
    HapticFeedback.selectionClick();

    setState(() {
      _digits.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1E36).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.pinError != null
                    ? Colors.redAccent
                    : const Color(0xFF00E676).withValues(alpha: 0.4),
                width: widget.pinError != null ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.pinError != null
                      ? Colors.redAccent.withValues(alpha: 0.3)
                      : const Color(0xFF00E676).withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'LOCKER ACCESS',
                  style: TextStyle(
                    color: Color(0xFF00E676),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.pinError ?? 'Enter 4-Digit Captain PIN',
                  style: TextStyle(
                    color: widget.pinError != null ? Colors.redAccent : Colors.white70,
                    fontSize: 12,
                    fontWeight: widget.pinError != null ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // 4-Digit Slot Displays
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final bool isFilled = index < _digits.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 44,
                      height: 52,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isFilled
                            ? (widget.pinError != null
                                ? Colors.redAccent.withValues(alpha: 0.2)
                                : const Color(0xFF00E676).withValues(alpha: 0.2))
                            : const Color(0xFF0F243E).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isFilled
                              ? (widget.pinError != null ? Colors.redAccent : const Color(0xFF00E676))
                              : Colors.white12,
                          width: isFilled ? 1.5 : 1.0,
                        ),
                        boxShadow: isFilled
                            ? [
                                BoxShadow(
                                  color: (widget.pinError != null ? Colors.redAccent : const Color(0xFF00E676))
                                      .withValues(alpha: 0.4),
                                  blurRadius: 10,
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: widget.loading && index == _digits.length - 1
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00E676)),
                              )
                            : Text(
                                isFilled ? '•' : '',
                                style: TextStyle(
                                  color: widget.pinError != null ? Colors.redAccent : const Color(0xFF00E676),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),

                // 3x4 Scoreboard Numpad Grid
                Column(
                  children: [
                    _buildNumpadRow(['1', '2', '3']),
                    const SizedBox(height: 8),
                    _buildNumpadRow(['4', '5', '6']),
                    const SizedBox(height: 8),
                    _buildNumpadRow(['7', '8', '9']),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 64, height: 44),
                        _buildNumpadButton('0'),
                        SizedBox(
                          width: 64,
                          height: 44,
                          child: InkWell(
                            onTap: _handleDelete,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                              ),
                              child: const Center(
                                child: Text(
                                  'DEL',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumpadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildNumpadButton(d)).toList(),
    );
  }

  Widget _buildNumpadButton(String digit) {
    return SizedBox(
      width: 64,
      height: 44,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handlePress(digit),
          borderRadius: BorderRadius.circular(10),
          splashColor: const Color(0xFF00E676).withValues(alpha: 0.3),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F243E).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: Center(
              child: Text(
                digit,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
