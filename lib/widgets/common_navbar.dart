import 'package:flutter/material.dart';

class CommonNavBar extends StatelessWidget {
  const CommonNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'id': '/welcome', 'icon': Icons.home, 'label': 'Home'},
      {'id': '/journal', 'icon': Icons.book, 'label': 'Journal'},
      {'id': '/flashcard', 'icon': Icons.school, 'label': 'Flashcards'},
      {'id': '/medicine', 'icon': Icons.medical_services, 'label': 'Medicine'},
      {'id': '/reminders', 'icon': Icons.alarm, 'label': 'Reminders'},
      {'id': '/profile', 'icon': Icons.person, 'label': 'Profile'},
    ];

    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    int currentIndex = items.indexWhere((i) => i['id'] == currentRoute);
    if (currentIndex < 0) currentIndex = 0;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        final targetRoute = items[index]['id'] as String;
        if (targetRoute == currentRoute) return;

        if (targetRoute == '/welcome') {
          Navigator.pushNamedAndRemoveUntil(context, targetRoute, (r) => false);
        } else {
          Navigator.pushReplacementNamed(context, targetRoute);
        }
      },
      items: items
          .map(
            (i) => BottomNavigationBarItem(
              icon: Icon(i['icon'] as IconData),
              label: i['label'] as String,
            ),
          )
          .toList(),
    );
  }
}
