import 'package:flutter/material.dart';

class ContactAdminScreen extends StatelessWidget {
  const ContactAdminScreen({super.key});

  void _navigateTo(BuildContext context, String route) {
    Navigator.pop(context); // Close the drawer
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Admin'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/dashboard'),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Deliveries'),
              onTap: () => _navigateTo(context, '/deliveries'),
            ),
            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text('Completed'),
              onTap: () => _navigateTo(context, '/completed'),
            ),
            ListTile(
              leading: const Icon(Icons.person_4_outlined),
              title: const Text('Profile'),
              onTap: () => _navigateTo(context, '/profile'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => _navigateTo(context, '/settings'),
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Contact admin'),
              onTap: () => _navigateTo(context, '/contact-admin'),
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              onTap: () => _navigateTo(context, '/help-support'),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Contact Admin Page'),
      ),
    );
  }
}
