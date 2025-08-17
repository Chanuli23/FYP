// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const ListTile(
            leading: Icon(Icons.phone, color: Colors.blue),
            title: Text('Phone'),
            subtitle: Text('+1234567890'),
          ),
          const ListTile(
            leading: Icon(Icons.email, color: Colors.blue),
            title: Text('Email'),
            subtitle: Text('support@routex.com'),
          ),
          const Divider(),
          const Text(
            'FAQs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 10),
          ExpansionTile(
            title: const Text('How do I reset my password?'),
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'To reset your password, go to the login page and click on "Forgot Password". Follow the instructions sent to your email.',
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('How do I contact support?'),
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'You can contact support via the phone number or email provided above.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
