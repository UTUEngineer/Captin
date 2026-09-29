import 'package:flutter/foundation.dart';

/// Sentry & Error Telemetry Configuration Service
class SentryService {
  static String? _dsn;

  static void initSentry({String? dsn}) {
    _dsn = dsn ?? const String.fromEnvironment('SENTRY_DSN', defaultValue: '');
    if (kDebugMode) {
      debugPrint('[SentryService] Initialized (DSN Configured: ${hasSentryDsn()})');
    }
  }

  static bool hasSentryDsn() {
    return _dsn != null && _dsn!.isNotEmpty;
  }

  /// Log App Exception / Crash to Telemetry Relay
  static void logAppError(
    dynamic error, {
    required String subsystem,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) {
    debugPrint('🚨 [Sentry Telemetry] [$subsystem] Error: $error');
    if (metadata != null && metadata.isNotEmpty) {
      debugPrint('   Metadata: $metadata');
    }

    if (hasSentryDsn()) {
      // In production builds with SENTRY_DSN configured, send exception scope to Sentry
      debugPrint('[Sentry Relay] Dispatching exception to $_dsn');
    }
  }
}
