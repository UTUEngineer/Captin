abstract final class AppConstants {
  static const String appName = 'Captain';
  static const Duration splashDuration = Duration(milliseconds: 1800);

  /// Bundled policy (also at [docs/PRIVACY_POLICY.md]). Shown in-app when
  /// [privacyPolicyUrl] is empty; store listings still need a public URL.
  static const String bundledPrivacyPolicyAsset = 'docs/PRIVACY_POLICY.md';

  /// Public privacy policy URL for store listings and external browser.
  /// `--dart-define=PRIVACY_POLICY_URL=https://your-domain.com/privacy`
  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: '',
  );

  /// Optional terms-of-service URL for store listings and in-app link.
  static const String termsOfServiceUrl = String.fromEnvironment(
    'TERMS_OF_SERVICE_URL',
    defaultValue: '',
  );

  /// Contact for privacy and support (App Store Connect / Play Console / in-app).
  static const String supportEmail = 'ayoa@smartgateapp.com';
}
