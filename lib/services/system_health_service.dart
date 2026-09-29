import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum HealthStatus { online, degraded, failed }

class HealthResult {
  const HealthResult({
    required this.layer,
    required this.method,
    required this.status,
    required this.message,
    this.latencyMs,
  });

  final String layer;
  final String method;
  final HealthStatus status;
  final String message;
  final int? latencyMs;

  bool get isOperational => status == HealthStatus.online;
}

typedef _Outcome = (HealthStatus, String);

final systemHealthServiceProvider = Provider<SystemHealthService>(
  (ref) => SystemHealthService(Supabase.instance.client),
);

class SystemHealthService {
  SystemHealthService(this._client);

  final SupabaseClient _client;
  static const _timeout = Duration(seconds: 4);

  /// Runs every check in parallel. Order matches the UI rows.
  Future<List<HealthResult>> runAll() => Future.wait([
        checkDatabase(),
        checkRpc(),
        checkEdgeFunction(),
        checkRealtime(),
        checkRenderer(),
      ]);

  // ---------------------------------------------------------------------------
  // 1. Postgres via PostgREST — real table read, RLS-aware
  // ---------------------------------------------------------------------------
  Future<HealthResult> checkDatabase() => _run(
        layer: 'Postgres Database',
        method: 'REST · captains',
        body: () async {
          final rows = await _client.from('captains').select('id').limit(1);
          if ((rows as List).isEmpty) {
            // RLS denial on SELECT is silent: 200 + empty list, not an error.
            return (
              HealthStatus.degraded,
              'HTTP 200 but 0 rows — table empty or RLS filtering this user',
            );
          }
          return (HealthStatus.online, 'HTTP 200 · read OK');
        },
      );

  // ---------------------------------------------------------------------------
  // 2. RPC gateway — side-effect-free function (see health_check.sql)
  // ---------------------------------------------------------------------------
  Future<HealthResult> checkRpc() => _run(
        layer: 'RPC Gateway',
        method: 'rpc · health_check',
        body: () async {
          final data = await _client.rpc('health_check');
          if (data is Map && data['ok'] == true) {
            return (HealthStatus.online, 'DB time ${data['db_time']}');
          }
          return (HealthStatus.degraded, 'Unexpected response: $data');
        },
      );

  // ---------------------------------------------------------------------------
  // 3. Edge Functions — dedicated `health` function (see index.ts)
  // ---------------------------------------------------------------------------
  Future<HealthResult> checkEdgeFunction() => _run(
        layer: 'Edge Functions',
        method: 'functions/v1 · health',
        body: () async {
          final res = await _client.functions.invoke(
            'health',
            method: HttpMethod.get,
          );
          final data = res.data;
          if (data is Map && data['ok'] == true) {
            return (HealthStatus.online, 'HTTP ${res.status}');
          }
          return (HealthStatus.degraded, 'HTTP ${res.status}, unexpected body');
        },
      );

  // ---------------------------------------------------------------------------
  // 4. Realtime — join + broadcast echo (proves messages actually flow)
  // ---------------------------------------------------------------------------
  Future<HealthResult> checkRealtime() => _run(
        layer: 'Realtime Engine',
        method: 'WebSocket · broadcast echo',
        body: () async {
          final done = Completer<_Outcome>();
          final joinWatch = Stopwatch()..start();
          int? joinMs;

          final channel = _client.channel(
            'health-check-${DateTime.now().microsecondsSinceEpoch}',
            opts: const RealtimeChannelConfig(self: true),
          );

          channel.onBroadcast(
            event: 'ping',
            callback: (_) {
              if (!done.isCompleted) {
                done.complete((
                  HealthStatus.online,
                  'Joined in ${joinMs}ms · echo received',
                ));
              }
            },
          );

          channel.subscribe((status, error) {
            if (done.isCompleted) return;
            switch (status) {
              case RealtimeSubscribeStatus.subscribed:
                joinMs = joinWatch.elapsedMilliseconds;
                unawaited(channel.sendBroadcastMessage(
                  event: 'ping',
                  payload: {'t': DateTime.now().millisecondsSinceEpoch},
                ));
              case RealtimeSubscribeStatus.channelError:
                done.complete((
                  HealthStatus.failed,
                  'Channel error: ${error ?? 'unknown'}',
                ));
              case RealtimeSubscribeStatus.timedOut:
                done.complete((HealthStatus.failed, 'Join timed out'));
              case RealtimeSubscribeStatus.closed:
                done.complete((HealthStatus.failed, 'Channel closed before echo'));
            }
          });

          try {
            return await done.future.timeout(
              _timeout,
              onTimeout: () => joinMs == null
                  ? (HealthStatus.failed, 'No join within ${_timeout.inSeconds}s')
                  : (HealthStatus.degraded, 'Joined in ${joinMs}ms but no echo'),
            );
          } finally {
            await _client.removeChannel(channel);
          }
        },
      );

  // ---------------------------------------------------------------------------
  // 5. Renderer — offscreen raster through the active pipeline + pixel check
  // ---------------------------------------------------------------------------
  Future<HealthResult> checkRenderer() => _run(
        layer: 'Graphics Renderer',
        method: kIsWeb
            ? 'Web renderer · offscreen raster'
            : 'Impeller/Skia · offscreen raster',
        body: () async {
          const size = 8;
          const probe = ui.Color(0xFF00E5FF); // R=0x00 G=0xE5 B=0xFF

          final recorder = ui.PictureRecorder();
          ui.Canvas(recorder).drawRect(
            ui.Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
            ui.Paint()..color = probe,
          );
          final picture = recorder.endRecording();
          final image = await picture.toImage(size, size);

          try {
            final bytes =
                await image.toByteData(format: ui.ImageByteFormat.rawRgba);
            if (bytes == null) {
              return (HealthStatus.failed, 'Rasterizer returned no pixels');
            }
            final px = [for (var i = 0; i < 4; i++) bytes.getUint8(i)];
            const expected = [0x00, 0xE5, 0xFF, 0xFF];
            final ok = [
              for (var i = 0; i < 4; i++) (px[i] - expected[i]).abs() <= 2,
            ].every((m) => m);

            return ok
                ? (HealthStatus.online, 'Rendered ${size}x$size · pixel check passed')
                : (HealthStatus.degraded, 'Pixel mismatch: $px');
          } finally {
            picture.dispose();
            image.dispose();
          }
        },
      );

  // ---------------------------------------------------------------------------
  // Shared runner: timing, timeout, typed error messages
  // ---------------------------------------------------------------------------
  Future<HealthResult> _run({
    required String layer,
    required String method,
    required Future<_Outcome> Function() body,
  }) async {
    final sw = Stopwatch()..start();
    HealthResult result(HealthStatus s, String m) => HealthResult(
          layer: layer,
          method: method,
          status: s,
          message: m,
          latencyMs: sw.elapsedMilliseconds,
        );

    try {
      // Slightly longer than inner timeouts so realtime can report its own.
      final (status, message) =
          await body().timeout(_timeout + const Duration(seconds: 1));
      return result(status, message);
    } on TimeoutException {
      return result(HealthStatus.failed, 'Timed out');
    } on PostgrestException catch (e) {
      return result(HealthStatus.failed, 'Postgres ${e.code ?? ''}: ${e.message}');
    } on FunctionException catch (e) {
      return result(
        HealthStatus.failed,
        'Edge function HTTP ${e.status}: ${e.details ?? e.reasonPhrase ?? ''}',
      );
    } on AuthException catch (e) {
      return result(HealthStatus.failed, 'Auth ${e.statusCode ?? ''}: ${e.message}');
    } catch (e) {
      return result(HealthStatus.failed, e.toString());
    }
  }
}
