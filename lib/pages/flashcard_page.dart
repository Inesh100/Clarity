import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/flashcard_vm.dart';
import '../viewmodels/auth_vm.dart';
import '../models/flashcard_model.dart';
import '../widgets/common_navbar.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  final questionCtrl = TextEditingController();
  final answerCtrl = TextEditingController();
  bool showAnswer = false;

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final vm = Provider.of<FlashcardViewModel>(context);
    final uid = authVm.firebaseUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards')),
      body: uid == null
          ? const Center(child: Text('Sign in to access flashcards'))
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // Input area for new flashcard
                  TextField(
                    controller: questionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Question',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: answerCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Answer',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (questionCtrl.text.isEmpty || answerCtrl.text.isEmpty) return;
                      vm.addCard(uid, questionCtrl.text, answerCtrl.text);
                      questionCtrl.clear();
                      answerCtrl.clear();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Flashcard'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Flashcards list
                  Expanded(
                    child: StreamBuilder<List<Flashcard>>(
                      stream: vm.streamCards(uid),
                      builder: (context, snap) {
                        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                        final cards = snap.data!;
                        if (cards.isEmpty) return const Center(child: Text('No flashcards'));

                        return ListView.builder(
                          itemCount: cards.length,
                          itemBuilder: (ctx, i) {
                            final c = cards[i];
                            return GestureDetector(
                              onTap: () => setState(() => showAnswer = !showAnswer),
                              child: Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        c.question,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      AnimatedCrossFade(
                                        firstChild: const SizedBox.shrink(),
                                        secondChild: Text(
                                          c.answer,
                                          style: const TextStyle(fontSize: 18, color: Colors.blueGrey),
                                        ),
                                        crossFadeState: showAnswer
                                            ? CrossFadeState.showSecond
                                            : CrossFadeState.showFirst,
                                        duration: const Duration(milliseconds: 300),
                                      ),
                                      const SizedBox(height: 12),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => vm.deleteCard(c.id),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const CommonNavBar(),
    );
  }
}
