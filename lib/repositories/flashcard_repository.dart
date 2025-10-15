import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/flashcard_model.dart';

class FlashcardRepository {
  final _col = FirebaseFirestore.instance.collection('flashcards');

  Future<void> addCard(Flashcard c) => _col.doc(c.id).set(c.toMap());
  Stream<List<Flashcard>> getCards(String uid) =>
    _col.where('userId', isEqualTo: uid).snapshots().map((snap) => snap.docs.map((d) => Flashcard.fromMap(d.data())).toList());
  Future<void> deleteCard(String id) => _col.doc(id).delete();
}
