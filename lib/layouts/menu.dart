import 'package:akunaki_app/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Menu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const Menu({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  Future<void> _deleteLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('token');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () async {
              await _deleteLoginStatus();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const TopPage()),
                  (route) => false,
                );
              }
            },
            child: const Icon(
              Icons.logout,
              size: 32,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMenuItem(Icons.home, 'Home', 0),
            _buildMenuItem(Icons.push_pin, 'Pins', 1),
            _buildMenuItem(Icons.train, 'Rails', 2),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Builder(
        builder: (BuildContext context) {
          final colorScheme = Theme.of(context).colorScheme;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: selectedIndex == index
                      ? colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      color: selectedIndex == index
                          ? Colors.white
                          : colorScheme.tertiary,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: selectedIndex == index
                            ? Colors.white
                            : colorScheme.tertiary,
                        fontWeight: selectedIndex == index
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
