import 'package:captain/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Rebuilds every descendant when the active [CaptainPalette] changes.
///
/// Most widgets read colors through the static [AppColors] getters rather
/// than `Theme.of(context)`, so they don't depend on an inherited widget.
/// When the user switches light/dark we mark the whole subtree dirty once —
/// widget state (scroll positions, forms, boards) is preserved.
class PaletteScope extends StatefulWidget {
  const PaletteScope({
    super.key,
    required this.palette,
    required this.child,
  });

  final CaptainPalette palette;
  final Widget child;

  static CaptainPalette of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_PaletteInherited>()
            ?.palette ??
        AppColors.palette;
  }

  @override
  State<PaletteScope> createState() => _PaletteScopeState();
}

class _PaletteScopeState extends State<PaletteScope> {
  @override
  void didUpdateWidget(covariant PaletteScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.palette, widget.palette)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        void rebuild(Element element) {
          element.markNeedsBuild();
          element.visitChildren(rebuild);
        }

        (context as Element).visitChildren(rebuild);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PaletteInherited(palette: widget.palette, child: widget.child);
  }
}

class _PaletteInherited extends InheritedWidget {
  const _PaletteInherited({required this.palette, required super.child});

  final CaptainPalette palette;

  @override
  bool updateShouldNotify(_PaletteInherited oldWidget) =>
      !identical(oldWidget.palette, palette);
}
