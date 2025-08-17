import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:routex/Guests/guest_profile_screen.dart';
import 'package:routex/Guests/guest_activities_screen.dart';
import 'package:routex/Guests/guest_settings_screen.dart';
import 'package:routex/Guests/guest_orders_screen.dart';

class GuestHomeScreen extends StatelessWidget {
  const GuestHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the logged-in user's name
    final user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? "User";

    // Example user data
    const String tier = "Blue";
    const int stars = 70;
    const int nextTierStars = 100;
    const String nextTier = "Bronze";
    const String unlockDate = "2024-07-15";
    const String email = "john.doe@email.com";
    const String mobile = "+94712345678";

    int selectedIndex = 0; // Home tab

    void onTabTapped(int index) {
      if (index == selectedIndex) return;
      switch (index) {
        case 0:
          // Already on Home
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const GuestSettingsScreen()),
          );
          break;
      }
    }

    // Get current date and time
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);
    final formattedTime = DateFormat('hh:mm:ss a').format(now);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message and date/time with three-dot menu
            Padding(
              padding: const EdgeInsets.only(
                  top: 24, left: 24, right: 24, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Welcome and date/time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $userName!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$formattedDate | $formattedTime',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  // Three-dot menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.blue),
                    onSelected: (value) async {
                      if (value == 'Profile') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GuestProfileScreen(),
                          ),
                        );
                      } else if (value == 'Logout') {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'Profile',
                        child: ListTile(
                          leading: Icon(Icons.person, color: Colors.blue),
                          title: Text('Profile'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'Logout',
                        child: ListTile(
                          leading: Icon(Icons.logout, color: Colors.red),
                          title: Text('Logout'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Use Expanded with SingleChildScrollView to avoid overflow
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 32, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue[700],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Tier badge/shield
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.shade200,
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.shield,
                                    color: Colors.blue[700], size: 40),
                              ),
                              const SizedBox(width: 12),
                              // Decorative stars (removed as per request)
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            tier,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Loyalty Tier",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2 rows, 3 boxes per row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Orders box with navigation
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const GuestOrdersScreen(),
                                      ),
                                    );
                                  },
                                  child: const _HomeFeatureBox(
                                    icon: Icons.shopping_cart,
                                    label: "Orders",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const _HomeFeatureBox(
                                  icon: Icons.favorite, label: "Favorites"),
                              const SizedBox(width: 12),
                              const _HomeFeatureBox(
                                  icon: Icons.notifications, label: "Alerts"),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Row(
                            children: [
                              _HomeFeatureBox(
                                  icon: Icons.card_giftcard, label: "Rewards"),
                              SizedBox(width: 12),
                              _HomeFeatureBox(
                                  icon: Icons.support_agent, label: "Support"),
                              SizedBox(width: 12),
                              _HomeFeatureBox(icon: Icons.info, label: "About"),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Navigation Bar
            Container(
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
                      color: Colors.blue,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onTabTapped(1),
                    child: _NavBarItem(
                      icon: Icons.person,
                      label: "Profile",
                      selected: selectedIndex == 1,
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

// Add this widget at the end of the file
class _HomeFeatureBox extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HomeFeatureBox({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
