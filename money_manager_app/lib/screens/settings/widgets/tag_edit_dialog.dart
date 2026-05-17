import 'package:flutter/material.dart';

import '../../../models/tag.dart';
import '../../../services/storage_service.dart';
import '../../../services/tag_service.dart';
import '../../../utils/contrast_utils.dart';

class TagEditDialog extends StatefulWidget {
  final Tag? editTag;

  const TagEditDialog({super.key, this.editTag});

  static Future<bool?> show(BuildContext context, {Tag? editTag}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => TagEditDialog(editTag: editTag),
    );
  }

  @override
  State<TagEditDialog> createState() => _TagEditDialogState();
}

class _TagEditDialogState extends State<TagEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _hexController;
  late String _selectedColor;
  bool _isLoading = false;

  static const _presetColors = [
    '#FF5252', '#FF4081', '#E040FB', '#536DFE',
    '#448AFF', '#18FFFF', '#64FFDA', '#69F0AE',
    '#FFD740', '#FF6E40', '#A1887F', '#9E9E9E',
  ];

  bool get _isEditing => widget.editTag != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.editTag?.name ?? '');
    _selectedColor = widget.editTag?.color ?? _presetColors[0];
    _hexController = TextEditingController(text: _selectedColor);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultTagId = StorageService.instance.getAllTags().firstOrNull?.id;
    final isOnlyTag = _isEditing && widget.editTag!.id == defaultTagId &&
        StorageService.instance.getAllTags().length == 1;

    return AlertDialog(
      scrollable: true,
      title: Text(_isEditing ? 'Edit Tag' : 'Add Tag'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name *'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              Text('Color', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presetColors.map((c) => GestureDetector(
                  onTap: () => setState(() {
                    _selectedColor = c;
                    _hexController.text = c;
                  }),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _parseColor(c),
                      shape: BoxShape.circle,
                      border: _selectedColor == c
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: _selectedColor == c
                          ? [BoxShadow(color: _parseColor(c).withValues(alpha: 0.5), blurRadius: 6)]
                          : null,
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hexController,
                decoration: const InputDecoration(
                  labelText: 'Hex Color',
                  prefixText: '#',
                ),
                onChanged: (v) {
                  final h = '#$v';
                  if (h.length == 7 && RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(h)) {
                    setState(() => _selectedColor = h);
                  }
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _parseColor(_selectedColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _nameController.text.isEmpty ? 'Preview' : _nameController.text,
                  style: TextStyle(
                    color: ContrastUtils.getTextColorForBackground(_selectedColor),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isOnlyTag)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Cannot delete the only tag. Add another tag first.',
                    style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        if (isOnlyTag && _isEditing)
          TextButton(
            onPressed: null,
            child: Text('Delete', style: TextStyle(color: Colors.grey.shade400)),
          )
        else if (_isEditing)
          TextButton(
            onPressed: () => _delete(context),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(_selectedColor)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid hex color')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final tagService = TagService(StorageService.instance);
      if (_isEditing) {
        await tagService.editTag(widget.editTag!.id, _nameController.text.trim(), _selectedColor);
      } else {
        await tagService.addTag(_nameController.text.trim(), _selectedColor);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  void _delete(BuildContext context) {
    final tagService = TagService(StorageService.instance);
    final hasTransactions =
        StorageService.instance.getTransactionsByTag(widget.editTag!.id).isNotEmpty;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Tag'),
        content: Text(hasTransactions
            ? 'Delete "${widget.editTag!.name}"? Transactions using it will be reassigned to the default tag.'
            : 'Delete "${widget.editTag!.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await tagService.deleteTag(widget.editTag!.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) Navigator.pop(context, true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}
