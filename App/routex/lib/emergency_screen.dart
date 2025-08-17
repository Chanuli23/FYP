import 'package:flutter/material.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency'),
        backgroundColor: Colors.red,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ListTile(
            leading: Icon(Icons.phone, color: Colors.red),
            title: Text('Emergency Hotline'),
            subtitle: Text('911'),
          ),
          ListTile(
            leading: Icon(Icons.local_hospital, color: Colors.red),
            title: Text('Nearest Hospital'),
            subtitle: Text('Tap to view on map'),
            onTap: null, // Add navigation to map or hospital details
          ),
          ListTile(
            leading: Icon(Icons.security, color: Colors.red),
            title: Text('Police Station'),
            subtitle: Text('Tap to view on map'),
            onTap: null, // Add navigation to map or police station details
          ),
          ListTile(
            leading: Icon(Icons.car_repair, color: Colors.red),
            title: Text('Nearest Garage'),
            subtitle: Text('Tap to view on map'),
            onTap: null, // Add navigation to map or garage details
          ),
          Divider(),
          Text(
            'Emergency Tips',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.info, color: Colors.red),
            title: Text('Stay Calm'),
            subtitle: Text('Try to remain calm and assess the situation.'),
          ),
          ListTile(
            leading: Icon(Icons.info, color: Colors.red),
            title: Text('Call for Help'),
            subtitle: Text('Use the emergency hotline or contact authorities.'),
          ),
        ],
      ),
    );
  }
}
