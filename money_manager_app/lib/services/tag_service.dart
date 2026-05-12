import '../models/tag.dart';
import 'storage_service.dart';

class TagService {
  final StorageService _storage;

  TagService(this._storage);

  Future<String> addTag(String name, String color) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Tag name cannot be empty');
    }
    if (!_isValidHex(color)) {
      throw ArgumentError('Invalid hex color: $color');
    }
    return await _storage.createTag(name: name.trim(), color: color);
  }

  Future<void> editTag(String id, String name, String color) async {
    final tag = _storage.getTag(id);
    if (tag == null) {
      throw StateError('Tag not found');
    }
    if (name.trim().isEmpty) {
      throw ArgumentError('Tag name cannot be empty');
    }
    if (!_isValidHex(color)) {
      throw ArgumentError('Invalid hex color: $color');
    }
    await _storage.updateTag(
      tag.copyWith(name: name.trim(), color: color),
    );
  }

  Future<void> deleteTag(String id) async {
    final tag = _storage.getTag(id);
    if (tag == null) return;

    final transactions = _storage.getTransactionsByTag(id);
    if (transactions.isNotEmpty) {
      final defaultTag = _storage.getAllTags().firstWhere(
            (t) => t.id != id,
        orElse: () => _storage.getAllTags().first,
      );
      for (final tx in transactions) {
        await _storage.updateTransaction(tx.copyWith(tagId: defaultTag.id));
      }
    }
    await _storage.deleteTag(id);
  }

  List<Tag> getAllTags() => _storage.getAllTags();

  Tag? getTag(String id) => _storage.getTag(id);

  bool isTagInUse(String id) =>
      _storage.getTransactionsByTag(id).isNotEmpty;

  bool tagNameExists(String name) => _storage.tagNameExists(name);

  bool _isValidHex(String hex) {
    final h = hex.replaceFirst('#', '');
    if (h.length != 6 && h.length != 8) return false;
    return RegExp(r'^[0-9A-Fa-f]+$').hasMatch(h);
  }
}
