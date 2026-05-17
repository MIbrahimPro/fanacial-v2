import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/person.dart';
import '../../../providers/loans_provider.dart';

class AddPersonDialog extends StatefulWidget {
  final Person? editPerson;

  const AddPersonDialog({super.key, this.editPerson});

  static Future<bool?> show(BuildContext context, {Person? editPerson}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AddPersonDialog(editPerson: editPerson),
    );
  }

  @override
  State<AddPersonDialog> createState() => _AddPersonDialogState();
}

class _AddPersonDialogState extends State<AddPersonDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isLoading = false;

  bool get _isEditing => widget.editPerson != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.editPerson?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(_isEditing ? 'Edit Person' : 'Add Person'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Name *',
            hintText: 'e.g. Alice',
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Name is required';
            final trimmed = v.trim();
            if (!_isEditing) {
              final provider = context.read<LoansProvider>();
              if (provider.personNameExists(trimmed)) {
                return 'A person with this name already exists';
              }
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final provider = context.read<LoansProvider>();
      final name = _nameController.text.trim();
      if (_isEditing) {
        await provider.updatePerson(widget.editPerson!.copyWith(name: name));
      } else {
        await provider.addPerson(name);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }
}
