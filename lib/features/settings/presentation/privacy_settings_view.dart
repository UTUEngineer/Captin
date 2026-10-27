import 'package:captain/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class PrivacySettingsView extends StatefulWidget {
  final String apiBaseUrl;

  const PrivacySettingsView({
    super.key,
    this.apiBaseUrl = 'https://api.captaintactics.com',
  });

  @override
  State<PrivacySettingsView> createState() => _PrivacySettingsViewState();
}

class _PrivacySettingsViewState extends State<PrivacySettingsView> {
  bool _isDeleting = false;
  bool _isExporting = false;

  Future<void> _handleDataExport() async {
    setState(() => _isExporting = true);
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;

    try {
      final res = await http.get(
        Uri.parse('${widget.apiBaseUrl}/api/v1/compliance/export-data'),
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );

      if (mounted) {
        setState(() => _isExporting = false);
        if (res.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Your tactical data export has been prepared.')),
          );
        } else {
          throw Exception('Export failed');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate data export.')),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(
          'Delete Account Permanently?',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This action is irreversible. All your tactical whiteboard templates, match footage, tracking telemetry, and AI scouting reports will be permanently destroyed.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete Everything', style: TextStyle(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _executeAccountPurge();
    }
  }

  Future<void> _executeAccountPurge() async {
    setState(() => _isDeleting = true);
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;

    try {
      final response = await http.delete(
        Uri.parse('${widget.apiBaseUrl}/api/v1/compliance/delete-account'),
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );

      if (response.statusCode == 200) {
        // Sign out locally
        await Supabase.instance.client.auth.signOut();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } else {
        throw Exception('Account deletion failed on server.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Privacy & Data Governance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Sovereignty & Portability',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Under GDPR and PDPL regulations, you have full ownership of your data. You can download a structured copy of your tactical boards or permanently delete your account at any time.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Export Data Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: AppColors.border),
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _isExporting ? null : _handleDataExport,
              icon: _isExporting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.download, size: 20),
              label: const Text('Export My Tactical Data (JSON)'),
            ),

            const SizedBox(height: 16),
            Divider(color: AppColors.border),
            const SizedBox(height: 16),

            const Text(
              'Danger Zone',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            const SizedBox(height: 12),

            // Delete Account Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _isDeleting ? null : _showDeleteConfirmationDialog,
              icon: _isDeleting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent))
                  : const Icon(Icons.delete_forever, size: 20),
              label: const Text('Permanently Delete My Account'),
            ),
          ],
        ),
      ),
    );
  }
}
