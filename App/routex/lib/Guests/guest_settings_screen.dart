import 'package:flutter/material.dart';
import 'guest_home_screen.dart';
import 'guest_profile_screen.dart';
import 'guest_activities_screen.dart';

class GuestSettingsScreen extends StatelessWidget {
  const GuestSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int selectedIndex = 3; // Settings tab

    void onTabTapped(int index) {
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const GuestHomeScreen()),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const GuestProfileScreen()),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const GuestActivitiesScreen()),
          );
          break;
        case 3:
          // Already on Settings
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.help_outline, color: Colors.blue),
                    label: const Text('Help Center',
                        style: TextStyle(
                            color: Colors.blue, fontFamily: 'Poppins')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      elevation: 0,
                      alignment: Alignment.centerLeft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 16),
                    ),
                    onPressed: () {
                      // TODO: Navigate to Help Center
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.language, color: Colors.blue),
                    label: const Text('Language Settings',
                        style: TextStyle(
                            color: Colors.blue, fontFamily: 'Poppins')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      elevation: 0,
                      alignment: Alignment.centerLeft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 16),
                    ),
                    onPressed: () {
                      // TODO: Navigate to Language Settings
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.favorite, color: Colors.blue),
                    label: const Text('Saved',
                        style: TextStyle(
                            color: Colors.blue, fontFamily: 'Poppins')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      elevation: 0,
                      alignment: Alignment.centerLeft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 16),
                    ),
                    onPressed: () {
                      // TODO: Navigate to Saved/Favorites
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.info_outline, color: Colors.blue),
                    label: const Text('About Us',
                        style: TextStyle(
                            color: Colors.blue, fontFamily: 'Poppins')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      elevation: 0,
                      alignment: Alignment.centerLeft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 16),
                    ),
                    onPressed: () {
                      // TODO: Navigate to About Us
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
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
                icon: Icons.payment,
                label: "Payments",
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
