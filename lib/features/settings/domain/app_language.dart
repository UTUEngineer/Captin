import 'package:flutter/material.dart';

enum AppLanguage {
  arabic('ar', 'العربية'),
  english('en', 'English');

  const AppLanguage(this.code, this.label);
  final String code;
  final String label;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (language) => language.code == code,
      orElse: () => AppLanguage.arabic,
    );
  }
}
