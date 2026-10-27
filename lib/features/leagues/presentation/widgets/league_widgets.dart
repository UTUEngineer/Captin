import 'package:cached_network_image/cached_network_image.dart';
import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/leagues/domain/standing.dart';
import 'package:flutter/material.dart';

/// Club crest with an initials fallback when the image is missing.
class TeamCrest extends StatelessWidget {
  const TeamCrest({super.key, required this.url, required this.name, this.size = 24});

  final String url;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        name.isEmpty ? '?' : name.characters.first,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: size * 0.45,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    if (url.isEmpty) return fallback;
    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => fallback,
    );
  }
}

/// W / D / L chips.
class FormChips extends StatelessWidget {
  const FormChips({super.key, required this.form, this.size = 18});

  final String form;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (form.isEmpty) {
      return Text('—', style: TextStyle(color: AppColors.textMuted));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final c in form.split(''))
          Container(
            width: size,
            height: size,
            margin: const EdgeInsetsDirectional.only(end: 3),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: switch (c) {
                'W' => AppColors.success,
                'D' => AppColors.textMuted,
                _ => AppColors.danger,
              },
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              switch (c) {
                'W' => 'ف',
                'D' => 'ت',
                _ => 'خ',
              },
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.55,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
      ],
    );
  }
}

Color zoneColor(StandingZone zone) => switch (zone) {
      StandingZone.championsLeague => AppColors.success,
      StandingZone.continental => AppColors.secondary,
      StandingZone.relegation => AppColors.danger,
      StandingZone.none => Colors.transparent,
    };

/// Small "sample data" banner shown when no API key is configured.
class SampleDataBanner extends StatelessWidget {
  const SampleDataBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'بيانات تجريبية للعرض — أضف مفتاح API-Football من الإعدادات لعرض النتائج الحقيقية.',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accent,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.topStart,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 18, color: color),
          if (icon != null) const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
