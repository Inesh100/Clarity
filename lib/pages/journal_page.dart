import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/journal_vm.dart';
import '../viewmodels/auth_vm.dart';
import '../models/journal_entry_model.dart';
import '../widgets/common_navbar.dart';
import '../styles/app_text.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});
  @override
  State<JournalPage> createState() => _JournalPageState();
}
class _JournalPageState extends State<JournalPage> {
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final vm = Provider.of<JournalViewModel>(context);
    final uid = authVm.firebaseUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      body: uid == null ? const Center(child: Text('Sign in')) : Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
          TextField(controller: contentCtrl, decoration: const InputDecoration(labelText: 'Content')),
          ElevatedButton(onPressed: () {
            vm.addEntry(uid, titleCtrl.text, contentCtrl.text);
            titleCtrl.clear(); contentCtrl.clear();
          }, child: const Text('Save')),
          const SizedBox(height: 12),
          const Text('Entries', style: AppTextStyles.heading2),
          Expanded(child: StreamBuilder<List<JournalEntry>>(
            stream: vm.streamEntries(uid),
            builder: (context, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final list = snap.data!;
              if (list.isEmpty) return const Center(child: Text('No entries'));
              return ListView.builder(itemCount: list.length, itemBuilder: (ctx,i){
                final e = list[i];
                return ListTile(
                  title: Text(e.title),
                  subtitle: Text(e.content),
                  trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => vm.deleteEntry(e.id)),
                );
              });
            },
          )),
        ]),
      ),
      bottomNavigationBar: const CommonNavBar(),
    );
  }
}
