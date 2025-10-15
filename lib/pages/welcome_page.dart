import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/common_navbar.dart';
import '../styles/app_text.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          Text('Welcome', style: AppTextStyles.heading1),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            ElevatedButton(onPressed: () => appState.setPage('journal'), child: const Text('Journal')),
            ElevatedButton(onPressed: () => appState.setPage('flashcard'), child: const Text('Flashcards')),
            ElevatedButton(onPressed: () => appState.setPage('reminders'), child: const Text('Reminders')),
            ElevatedButton(onPressed: () => appState.setPage('medicine'), child: const Text('Medicine')),
          ]),
          const Spacer(),
          const Text('Designed by Sedelle & Sade', style: AppTextStyles.small),
        ]),
      ),
      bottomNavigationBar: const CommonNavBar(),
    );
  }
}
