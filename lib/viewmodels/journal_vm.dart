import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/journal_entry_model.dart';
import '../repositories/journal_repository.dart';

class JournalViewModel extends ChangeNotifier {
  final _repo = JournalRepository();

  Stream<List<JournalEntry>> streamEntries(String userId) => _repo.getEntries(userId);

  Future<void> addEntry(String userId, String title, String content) async {
    final id = const Uuid().v4();
    final e = JournalEntry(id: id, userId: userId, title: title, content: content, createdAt: DateTime.now());
    await _repo.addEntry(e);
  }

  Future<void> deleteEntry(String id) => _repo.deleteEntry(id);
}
