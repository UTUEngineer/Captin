import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sentry_service.dart';
import '../services/system_health_service.dart';

/// Collapsible Diagnostics Debug Drawer Widget
class DebugDiagnosticsDrawer extends ConsumerStatefulWidget {
  const DebugDiagnosticsDrawer({super.key});

  @override
  ConsumerState<DebugDiagnosticsDrawer> createState() => _DebugDiagnosticsDrawerState();
}

class _DebugDiagnosticsDrawerState extends ConsumerState<DebugDiagnosticsDrawer> {
  bool _isOpen = false;
  bool _testing = false;
  List<HealthResult> _reports = [];

  Future<void> _runAllChecks() async {
    setState(() => _testing = true);

    final service = ref.read(systemHealthServiceProvider);
    final results = await service.runAll();

    if (mounted) {
      setState(() {
        _reports = results;
        _testing = false;
      });
    }
  }

  void _triggerTestSentryCrash() {
    try {
      throw Exception('[Captain App Test Error] Sentry integration verification.');
    } catch (err, stack) {
      SentryService.logAppError(
        err,
        subsystem: 'test_crash_btn',
        metadata: {'testTime': DateTime.now().toIso8601String()},
        stackTrace: stack,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.bug_report_rounded, color: Colors.amberAccent, size: 18),
              SizedBox(width: 10),
              Text('Simulated test exception sent to Sentry telemetry relay.'),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      bottom: 16,
      child: Material(
        color: Colors.transparent,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: !_isOpen
              ? _buildFloatingButton()
              : _buildExpandedDrawer(),
        ),
      ),
    );
  }

  Widget _buildFloatingButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() => _isOpen = true);
        _runAllChecks();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF091728).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'DIAGNOSTICS & SENTRY',
              style: TextStyle(
                color: Color(0xFF67E8F9),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedDrawer() {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF091728).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drawer Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF06B6D4),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'SYSTEM DIAGNOSTICS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => setState(() => _isOpen = false),
                icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subsystems (${_reports.length})',
                style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: _testing ? null : _runAllChecks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06B6D4).withValues(alpha: 0.2),
                  foregroundColor: const Color(0xFF67E8F9),
                  side: const BorderSide(color: Color(0xFF06B6D4)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  _testing ? 'Probing...' : 'Re-Run Checks',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Subsystem Reports List
          if (_testing && _reports.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4))),
            )
          else
            Column(
              children: _reports.map((item) => _buildSubsystemItem(item)).toList(),
            ),

          const SizedBox(height: 12),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 10),

          // Sentry Crash Test Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Verify Sentry Logging:',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
              OutlinedButton(
                onPressed: _triggerTestSentryCrash,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFDA4AF),
                  side: const BorderSide(color: Color(0xFFE11D48)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Send Test Exception',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubsystemItem(HealthResult item) {
    final bool isOnline = item.status == HealthStatus.online;
    final bool isDegraded = item.status == HealthStatus.degraded;

    final Color statusColor = isOnline
        ? const Color(0xFF10B981)
        : isDegraded
            ? const Color(0xFFFCD34D)
            : const Color(0xFFE11D48);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOnline ? Colors.white10 : statusColor.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.layer,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${item.method})',
                      style: const TextStyle(color: Colors.white38, fontSize: 8, fontFamily: 'monospace'),
                    ),
                  ],
                ),
                Text(
                  item.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 9),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withValues(alpha: 0.6)),
                ),
                child: Text(
                  item.status.name.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              if (item.latencyMs != null)
                Text(
                  '${item.latencyMs}ms',
                  style: const TextStyle(color: Colors.white38, fontSize: 8, fontFamily: 'monospace'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
