import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/flashcard_model.dart';
import '../repositories/flashcard_repository.dart';

class FlashcardViewModel extends ChangeNotifier {
  final _repo = FlashcardRepository();

  Stream<List<Flashcard>> streamCards(String userId) => _repo.getCards(userId);

  Future<void> addCard(String userId, String question, String answer) async {
    final id = const Uuid().v4();
    final c = Flashcard(id: id, userId: userId, question: question, answer: answer, createdAt: DateTime.now());
    await _repo.addCard(c);
  }

  Future<void> deleteCard(String id) => _repo.deleteCard(id);
}
