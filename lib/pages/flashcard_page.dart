import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/flashcard_vm.dart';
import '../viewmodels/auth_vm.dart';
import '../models/flashcard_model.dart';
import '../widgets/common_navbar.dart';
import '../styles/app_text.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  final qCtrl = TextEditingController();
  final aCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final vm = Provider.of<FlashcardViewModel>(context);
    final uid = authVm.firebaseUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Flash Cards')),
      body: uid == null
          ? const Center(child: Text('Sign in'))
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextField(
                    controller: qCtrl,
                    decoration: const InputDecoration(labelText: 'Question'),
                  ),
                  TextField(
                    controller: aCtrl,
                    decoration: const InputDecoration(labelText: 'Answer'),
                  ),
                  const SizedBox(height: 12),
                  const Text('Cards', style: AppTextStyles.heading2),
                  Expanded(
                    child: StreamBuilder<List<Flashcard>>(
                      stream: vm.streamCards(uid),
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final cards = snap.data!;
                        if (cards.isEmpty) {
                          return const Center(child: Text('No cards'));
                        }
                        return ListView.builder(
                          itemCount: cards.length,
                          itemBuilder: (ctx, i) {
                            final c = cards[i];
                            return ListTile(
                              title: Text(c.question),
                              subtitle: Text(c.answer),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => vm.deleteCard(c.id),
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

      // ✅ Replaces the "Add" text button with a FloatingActionButton
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (uid != null && qCtrl.text.isNotEmpty && aCtrl.text.isNotEmpty) {
            vm.addCard(uid, qCtrl.text, aCtrl.text);
            qCtrl.clear();
            aCtrl.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Flashcard added!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter both question and answer.')),
            );
          }
        },
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: const CommonNavBar(),
    );
  }
}
