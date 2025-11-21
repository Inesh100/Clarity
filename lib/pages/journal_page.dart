import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/journal_vm.dart';
import '../viewmodels/auth_vm.dart';
import '../models/journal_entry_model.dart';
import '../widgets/common_navbar.dart';
import '../styles/app_text.dart';
import '../styles/app_colors.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
      ),
      body: uid == null
          ? Center(
              child: Text(
                'Sign in',
                style: AppTextStyles.body.copyWith(color: theme.colorScheme.onBackground),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // Title input
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: AppTextStyles.body.copyWith(color: theme.colorScheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                      ),
                    ),
                    style: AppTextStyles.heading2.copyWith(color: theme.colorScheme.onBackground),
                  ),
                  const SizedBox(height: 12),

                  // Content input
                  Expanded(
                    child: TextField(
                      controller: contentCtrl,
                      decoration: InputDecoration(
                        labelText: 'Content',
                        labelStyle: AppTextStyles.body.copyWith(color: theme.colorScheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                        ),
                        alignLabelWithHint: true,
                      ),
                      style: AppTextStyles.body.copyWith(color: theme.colorScheme.onBackground),
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Entries', style: AppTextStyles.heading2),
                  ),
                  const SizedBox(height: 8),

                  // Journal entries list
                  Expanded(
                    child: StreamBuilder<List<JournalEntry>>(
                      stream: vm.streamEntries(uid),
                      builder: (context, snap) {
                        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                        final list = snap.data!;
                        if (list.isEmpty)
                          return Center(
                            child: Text(
                              'No entries',
                              style: AppTextStyles.body.copyWith(color: theme.colorScheme.onBackground),
                            ),
                          );

                        return ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (ctx, i) {
                            final e = list[i];
                            return Card(
                              color: theme.cardColor,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                title: Text(e.title,
                                    style: AppTextStyles.heading2.copyWith(color: theme.colorScheme.onSurface)),
                                subtitle: Text(e.content,
                                    style: AppTextStyles.body.copyWith(color: theme.colorScheme.onSurface)),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: AppColors.danger),
                                  onPressed: () => vm.deleteEntry(e.id),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Save button
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleCtrl.text.isEmpty && contentCtrl.text.isEmpty) return;
                        vm.addEntry(uid, titleCtrl.text, contentCtrl.text);
                        titleCtrl.clear();
                        contentCtrl.clear();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Icon(Icons.save, size: 28, color: theme.colorScheme.onPrimary),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const CommonNavBar(),
    );
  }
}
