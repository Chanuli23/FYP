import 'package:flutter/material.dart';

class GuestActivitiesScreen extends StatelessWidget {
  const GuestActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int selectedIndex = 2; // Activities tab

    void onTabTapped(int index) {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/guest_home');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/guest_profile');
          break;
        case 2:
          // Already on Activities
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/guest_settings');
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text(
          'This is the Activities page.',
          style: TextStyle(fontSize: 20, fontFamily: 'Poppins'),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => onTabTapped(0),
              child: _NavBarItem(
                icon: Icons.home,
                label: "Home",
                selected: selectedIndex == 0,
              ),
            ),
            GestureDetector(
              onTap: () => onTabTapped(1),
              child: _NavBarItem(
                icon: Icons.person,
                label: "Profile",
                selected: selectedIndex == 1,
                color: Colors.blue,
              ),
            ),
            GestureDetector(
              onTap: () => onTabTapped(2),
              child: _NavBarItem(
                icon: Icons.list_alt,
                label: "Activities",
                selected: selectedIndex == 2,
              ),
            ),
            GestureDetector(
              onTap: () => onTabTapped(3),
              child: _NavBarItem(
                icon: Icons.settings,
                label: "Settings",
                selected: selectedIndex == 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color? color;

  const _NavBarItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: selected ? (color ?? Colors.blue) : Colors.grey,
          size: 28,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? (color ?? Colors.blue) : Colors.grey,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}
