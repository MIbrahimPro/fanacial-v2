import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/sync_provider.dart';
import 'pin_entry_dialog.dart';

class SyncSection extends StatelessWidget {
  const SyncSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SyncProvider>();
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sync',
                  style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (provider.isSyncing)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          if (provider.syncEnabled) ...[
            ListTile(
              leading: Icon(
                provider.isSyncing ? Icons.sync : Icons.cloud_done,
                color: Colors.green,
              ),
              title: const Text('Status'),
              subtitle: Text(
                provider.isSyncing
                    ? 'Syncing...'
                    : 'Online',
              ),
            ),
            if (provider.lastSync != null)
              ListTile(
                leading: const Icon(Icons.access_time, color: Colors.grey),
                title: const Text('Last Sync'),
                subtitle: Text(
                  _formatAgo(provider.lastSync!),
                ),
              ),
            SwitchListTile(
              title: const Text('Auto Sync'),
              value: provider.autoSync,
              onChanged: (_) => provider.toggleAutoSync(),
              secondary: const Icon(Icons.sync),
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sync Now'),
              enabled: !provider.isSyncing,
              onTap: () async {
                final error = await provider.syncNow();
                if (error != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sync failed: $error')),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sync complete')),
                  );
                }
              },
              trailing: provider.isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
            ListTile(
              leading: Icon(Icons.lock_open, color: Colors.grey),
              title: const Text('Disable Sync'),
              onTap: () => _confirmDisable(context),
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.cloud_off, color: Colors.grey),
              title: const Text('Sync Disabled'),
              subtitle: const Text('Set up sync to backup your data'),
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Set Up Sync'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _handlePin(context),
            ),
            SwitchListTile(
              title: Text('Auto Sync', style: TextStyle(color: Colors.grey.shade400)),
              value: false,
              onChanged: null,
              secondary: Icon(Icons.sync, color: Colors.grey.shade400),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _handlePin(BuildContext context) async {
    final provider = context.read<SyncProvider>();
    if (!context.mounted) return;

    if (provider.hasPin) {
      final pin = await showDialog<String>(
        context: context,
        builder: (_) => const PinEntryDialog(),
      );
      if (pin == null || !context.mounted) return;
      final ok = await provider.verifyPinAndEnable(pin);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect PIN')),
        );
      }
    } else {
      final pin = await showDialog<String>(
        context: context,
        builder: (_) => const PinEntryDialog(isFirstTime: true),
      );
      if (pin == null || !context.mounted) return;
      final ok = await provider.setPin(pin);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to set PIN')),
        );
      }
    }
  }

  void _confirmDisable(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disable Sync?'),
        content: const Text('You can re-enable it later with your PIN.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<SyncProvider>().disableSync();
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }

  String _formatAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('d MMM, HH:mm').format(dt);
  }
}
