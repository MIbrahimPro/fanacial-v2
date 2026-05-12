import 'package:flutter/material.dart';

class SyncSection extends StatelessWidget {
  const SyncSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              'Sync',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_off, color: Colors.grey),
            title: const Text('Status'),
            subtitle: const Text('Offline — Coming soon'),
          ),
          SwitchListTile(
            title: const Text('Auto Sync'),
            value: false,
            onChanged: null,
            secondary: const Icon(Icons.sync, color: Colors.grey),
          ),
          ListTile(
            leading: const Icon(Icons.sync, color: Colors.grey),
            title: const Text('Sync Now'),
            subtitle: const Text('Coming in a future update'),
            enabled: false,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
