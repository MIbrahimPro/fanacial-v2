import 'package:flutter/material.dart';

import 'settings/widgets/sync_section.dart';
import 'settings/widgets/tag_list_section.dart';
import 'settings/widgets/theme_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ThemeSection(),
            const SyncSection(),
            const TagListSection(),
          ],
        ),
      ),
    );
  }
}
