import 'package:flutter/material.dart';

import '../../../models/tag.dart';
import '../../../services/storage_service.dart';
import '../../../services/tag_service.dart';
import '../../../utils/contrast_utils.dart';
import 'tag_edit_dialog.dart';

class TagListSection extends StatefulWidget {
  const TagListSection({super.key});

  @override
  State<TagListSection> createState() => _TagListSectionState();
}

class _TagListSectionState extends State<TagListSection> {
  int _refreshKey = 0;

  List<Tag> get _tags => StorageService.instance.getAllTags();

  @override
  Widget build(BuildContext context) {
    final tags = _tags;

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
                  'Tags',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                TextButton.icon(
                  onPressed: () => _addTag(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Tag'),
                ),
              ],
            ),
          ),
          if (tags.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No tags yet', style: TextStyle(color: Colors.grey)),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) => _TagPill(
                  tag: tag,
                  onTap: () => _editTag(context, tag),
                  onDelete: tags.length > 1
                      ? () => _deleteTag(context, tag)
                      : null,
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _addTag(BuildContext context) async {
    final result = await TagEditDialog.show(context);
    if (result == true) setState(() => _refreshKey++);
  }

  void _editTag(BuildContext context, Tag tag) async {
    final result = await TagEditDialog.show(context, editTag: tag);
    if (result == true) setState(() => _refreshKey++);
  }

  void _deleteTag(BuildContext context, Tag tag) {
    final hasTx = StorageService.instance.getTransactionsByTag(tag.id).isNotEmpty;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Tag'),
        content: Text(hasTx
            ? 'Delete "${tag.name}"? Transactions will use the default tag instead.'
            : 'Delete "${tag.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
            onPressed: () async {
              await TagService(StorageService.instance).deleteTag(tag.id);
              if (ctx.mounted) Navigator.pop(ctx);
              setState(() => _refreshKey++);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final Tag tag;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _TagPill({
    required this.tag,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = ContrastUtils.parseHex(tag.color);
    final textColor = ContrastUtils.getTextColorForBackground(tag.color);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag.name,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.close, size: 14, color: textColor.withValues(alpha: 0.7)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
