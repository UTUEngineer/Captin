import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/system_health_service.dart';

/// System Health Diagnostic Panel Widget / Dialog
class SystemHealthCheckDialog extends ConsumerStatefulWidget {
  const SystemHealthCheckDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const SystemHealthCheckDialog(),
    );
  }

  @override
  ConsumerState<SystemHealthCheckDialog> createState() => _SystemHealthCheckDialogState();
}

class _SystemHealthCheckDialogState extends ConsumerState<SystemHealthCheckDialog> {
  List<HealthResult> _results = [];
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isRunning = true;
    });

    final service = ref.read(systemHealthServiceProvider);
    final checks = await service.runAll();

    if (mounted) {
      setState(() {
        _results = checks;
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int onlineCount = _results.where((r) => r.isOperational).length;
    final int totalCount = _results.length;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.health_and_safety_rounded, color: Color(0xFF06B6D4), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'SYSTEM DIAGNOSTICS',
                      style: TextStyle(
                        color: Color(0xFF06B6D4),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _isRunning ? null : () {
                    HapticFeedback.lightImpact();
                    _runDiagnostics();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06B6D4).withValues(alpha: 0.2),
                    foregroundColor: const Color(0xFF67E8F9),
                    side: const BorderSide(color: Color(0xFF06B6D4)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: Text(
                    _isRunning ? 'Pinging...' : 'Test Services',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Diagnostic Results List
            if (_isRunning && _results.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
                ),
              )
            else
              Column(
                children: _results.map((r) => _buildResultTile(r)).toList(),
              ),

            const SizedBox(height: 16),

            // Summary Status Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    totalCount > 0 ? '$onlineCount / $totalCount Services Operational' : 'Running Health Checks...',
                    style: TextStyle(
                      color: onlineCount == totalCount
                          ? const Color(0xFF10B981)
                          : onlineCount > 0
                              ? const Color(0xFFFCD34D)
                              : const Color(0xFFE11D48),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 16),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultTile(HealthResult r) {
    final bool isOnline = r.status == HealthStatus.online;
    final bool isDegraded = r.status == HealthStatus.degraded;

    final Color statusColor = isOnline
        ? const Color(0xFF10B981)
        : isDegraded
            ? const Color(0xFFFCD34D)
            : const Color(0xFFE11D48);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF061120),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOnline
              ? Colors.white.withValues(alpha: 0.08)
              : statusColor.withValues(alpha: 0.4),
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
                      r.layer,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${r.method})',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 9,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  r.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 9),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                r.status.name.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                ),
              ),
              if (r.latencyMs != null)
                Text(
                  '${r.latencyMs}ms',
                  style: const TextStyle(color: Colors.white38, fontSize: 8, fontFamily: 'monospace'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
