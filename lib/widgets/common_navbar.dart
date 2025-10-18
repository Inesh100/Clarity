import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class CommonNavBar extends StatelessWidget {
  const CommonNavBar({super.key});
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final page = appState.selectedPage;
    final items = [
      {'id': 'welcome', 'icon': Icons.home, 'label': 'Home'},
      {'id': 'journal', 'icon': Icons.book, 'label': 'Journal'},
      {'id': 'flashcard', 'icon': Icons.school, 'label': 'Flashcards'},
      {'id': 'reminders', 'icon': Icons.alarm, 'label': 'Reminders'},
      {'id': 'profile', 'icon': Icons.person, 'label': 'Profile'},
    ];

    int idx = items.indexWhere((i) => i['id'] == page);
    if (idx < 0) idx = 0;

    return BottomNavigationBar(
      currentIndex: idx,
      onTap: (i) => appState.setPage(items[i]['id'] as String),
      items: items.map((it) => BottomNavigationBarItem(icon: Icon(it['icon'] as IconData), label: it['label'] as String)).toList(),
      type: BottomNavigationBarType.fixed,
    );
  }
}
