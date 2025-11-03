import 'package:flutter/material.dart';

class CommonNavBar extends StatelessWidget {
  const CommonNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'id': '/welcome', 'icon': Icons.home, 'label': 'Home'},
      {'id': '/journal', 'icon': Icons.book, 'label': 'Journal'},
      {'id': '/flashcard', 'icon': Icons.school, 'label': 'Flashcards'},
      {'id':'/medicine', 'icon': Icons.medical_services, 'label': 'Medicine'},
      {'id': '/reminders', 'icon': Icons.alarm, 'label': 'Reminders'},
      {'id': '/profile', 'icon': Icons.person, 'label': 'Profile'},
    ];

    // Determine current route name
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/welcome';
    int idx = items.indexWhere((i) => i['id'] == currentRoute);
    if (idx < 0) idx = 0;

    return BottomNavigationBar(
      currentIndex: idx,
      onTap: (i) {
        final targetRoute = items[i]['id'] as String;
        if (targetRoute != currentRoute) {
          Navigator.pushReplacementNamed(context, targetRoute);
        }
      },
      items: items
          .map((it) => BottomNavigationBarItem(
                icon: Icon(it['icon'] as IconData),
                label: it['label'] as String,
              ))
          .toList(),
      type: BottomNavigationBarType.fixed,
    );
  }
}
