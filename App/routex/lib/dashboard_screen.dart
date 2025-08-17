// ignore_for_file: unused_import, use_build_context_synchronously, library_private_types_in_public_api, deprecated_member_use, unused_field, use_key_in_widget_constructors, avoid_types_as_parameter_names, unused_element, unused_local_variable

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Add this for kIsWeb
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:routex/map_screen.dart';
import 'package:routex/edit_profile_screen.dart';
import 'package:routex/settings_screen.dart';
import 'package:routex/route_tasks_screen.dart'; // Ensure this import is present
import 'package:routex/help_support_screen.dart';
import 'package:routex/emergency_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  final List<Widget> _tabs = [
    const HomeTab(),
    const RouteTasksScreen(routeName: "Routes"),
    MapTab(),
    const EmergencyTab(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _tabs[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _animationController.forward(from: 0.0);
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home, color: Colors.black),
            label: tr('home'), // <-- localized
          ),
          BottomNavigationBarItem(
            icon:
                const Icon(Icons.directions_car_outlined, color: Colors.black),
            label: tr('routes'), // <-- localized
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map, color: Colors.black),
            label: tr('map'), // <-- localized
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.warning, color: Colors.red),
            label: tr('emergency'), // <-- localized
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  late Stopwatch _stopwatch;
  late Timer _timer;
  String _formattedDateTime = '';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String _userName = 'User'; // Default username
  String? _profileImageUrl;
  List<Map<String, dynamic>> _assignments = []; // List to store all assignments
  String _userAccountType = 'Driver'; // Track account type

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _formattedDateTime = _getFormattedDateTime();
    _startDateTimeUpdater();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    _fetchUserData();
    _fetchDriverAssignments();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Determine account type and fetch user info
        DocumentSnapshot driverDoc = await FirebaseFirestore.instance
            .collection('drivers')
            .doc(user.uid)
            .get();
        DocumentSnapshot guestDoc = await FirebaseFirestore.instance
            .collection('guests')
            .doc(user.uid)
            .get();

        if (driverDoc.exists) {
          _userAccountType = 'Driver';
          String? firestoreName = driverDoc['name'];
          setState(() {
            _userName = firestoreName ?? 'User';
            _profileImageUrl = driverDoc['profileImageUrl'];
          });
          await _fetchAssignmentsForDriver(firestoreName ?? '');
        } else if (guestDoc.exists) {
          _userAccountType = 'Guest';
          String? firestoreName = guestDoc['name'];
          setState(() {
            _userName = firestoreName ?? 'User';
            _profileImageUrl = guestDoc['profileImageUrl'];
          });
          await _fetchAssignmentsForGuest(user.email ?? '');
        } else {
          setState(() {
            _userName = user.displayName ?? 'User';
          });
          _assignments = [];
        }
      } catch (e) {
        debugPrint('Error fetching user data: $e');
        setState(() {
          _userName = user.displayName ?? 'User';
          _assignments = [];
        });
      }
    }
  }

  Future<void> _fetchAssignmentsForDriver(String driverName) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('assignments')
          .where('driver', isEqualTo: driverName)
          .get();

      setState(() {
        _assignments = querySnapshot.docs.map((doc) {
          final data = doc.data();
          // Format assignedAt timestamp if present
          String assignedAtStr = '';
          if (data['assignedAt'] != null && data['assignedAt'] is Timestamp) {
            final dt = (data['assignedAt'] as Timestamp).toDate();
            assignedAtStr = DateFormat('yyyy-MM-dd hh:mm a').format(dt);
          }
          // Capture routeId if present in assignment
          return {
            'vehicle': data['vehicle'] ?? 'Not Assigned',
            'route': data['route'] ?? 'Not Assigned',
            'routeId': data['routeId'], // Pass routeId through assignment
            'assignedAt': assignedAtStr,
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('Error fetching assignments for driver: $e');
      setState(() {
        _assignments = [];
      });
    }
  }

  Future<void> _fetchAssignmentsForGuest(String email) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('assignments')
          .where('guestEmail', isEqualTo: email)
          .get();

      setState(() {
        _assignments = querySnapshot.docs.map((doc) {
          final data = doc.data();
          String assignedAtStr = '';
          if (data['assignedAt'] != null && data['assignedAt'] is Timestamp) {
            final dt = (data['assignedAt'] as Timestamp).toDate();
            assignedAtStr = DateFormat('yyyy-MM-dd hh:mm a').format(dt);
          }
          return {
            'vehicle': data['vehicle'] ?? 'Not Assigned',
            'route': data['route'] ?? 'Not Assigned',
            'routeId': data['routeId'],
            'assignedAt': assignedAtStr,
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('Error fetching assignments for guest: $e');
      setState(() {
        _assignments = [];
      });
    }
  }

  // Only fetch assignments for drivers and show in dashboard
  Future<void> _fetchDriverAssignments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Get driver name from drivers collection
        final driverDoc = await FirebaseFirestore.instance
            .collection('drivers')
            .doc(user.uid)
            .get();
        if (driverDoc.exists) {
          final driverName = driverDoc['name'] ?? '';
          // Fetch assignments for this driver
          final querySnapshot = await FirebaseFirestore.instance
              .collection('assignments')
              .where('driver', isEqualTo: driverName)
              .get();
          setState(() {
            _assignments = querySnapshot.docs.map((doc) {
              final data = doc.data();
              String assignedAtStr = '';
              if (data['assignedAt'] != null &&
                  data['assignedAt'] is Timestamp) {
                final dt = (data['assignedAt'] as Timestamp).toDate();
                assignedAtStr = DateFormat('yyyy-MM-dd hh:mm a').format(dt);
              }
              return {
                'vehicle': data['vehicle'] ?? 'Not Assigned',
                'route': data['route'] ?? 'Not Assigned',
                'routeId': data['routeId'],
                'assignedAt': assignedAtStr,
              };
            }).toList();
          });
        } else {
          setState(() {
            _assignments = [];
          });
        }
      } catch (e) {
        debugPrint('Error fetching driver assignments: $e');
        setState(() {
          _assignments = [];
        });
      }
    }
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _timer.cancel();
    _fadeController.dispose(); // Dispose of the AnimationController
    super.dispose();
  }

  String _getFormattedDateTime() {
    final now = DateTime.now();
    return DateFormat('EEEE, MMMM d, yyyy | hh:mm:ss a').format(now);
  }

  void _startDateTimeUpdater() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _formattedDateTime = _getFormattedDateTime();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Top section with welcome message and profile
            Container(
              padding: const EdgeInsets.only(
                  top: 50, bottom: 30, left: 20, right: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage: _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : null,
                    child: _profileImageUrl == null
                        ? const Icon(Icons.person, color: Colors.blue, size: 35)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${tr('welcome')}, $_userName!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _formattedDateTime,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'Edit Profile') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      } else if (value == 'Settings') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      } else if (value == 'Help & Support') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpSupportScreen(),
                          ),
                        );
                      } else if (value == 'Logout') {
                        FirebaseAuth.instance.signOut();
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'Edit Profile',
                        child: ListTile(
                          leading: Icon(Icons.edit, color: Colors.blue),
                          title: Text('Edit Profile'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'Settings',
                        child: ListTile(
                          leading: Icon(Icons.settings, color: Colors.blue),
                          title: Text('Settings'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'Help & Support',
                        child: ListTile(
                          leading: Icon(Icons.help_outline, color: Colors.blue),
                          title: Text('Help & Support'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'Logout',
                        child: ListTile(
                          leading: Icon(Icons.logout, color: Colors.blue),
                          title: Text('Logout'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Professional dashboard section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDashboardCard(
                    icon: Icons.directions_car,
                    label: tr('total_vehicles'), // <-- localized
                    value: '12',
                    color: Colors.blue,
                  ),
                  _buildDashboardCard(
                    icon: Icons.route,
                    label: tr('active_routes'), // <-- localized
                    value: '6',
                    color: Colors.green,
                  ),
                  _buildDashboardCard(
                    icon: Icons.task_alt,
                    label: tr('completed_tasks'), // <-- localized
                    value: '25',
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // List of assignments
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _assignments.length,
                itemBuilder: (context, index) {
                  final assignment = _assignments[index];
                  return GestureDetector(
                    // Remove the onTap from GestureDetector, move navigation to the arrow icon
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueGrey.shade50,
                            Colors.blueGrey.shade200
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.assignment,
                                  color: Colors.indigo, size: 40),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Vehicle: ${assignment['vehicle']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                        color: Colors.indigo,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Route: ${assignment['route']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                        color: Colors.indigo,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // The following block displays the assigned date/time
                                    if (assignment['assignedAt'] != null &&
                                        assignment['assignedAt']
                                            .toString()
                                            .isNotEmpty)
                                      Text(
                                        'Assigned: ${assignment['assignedAt']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Poppins',
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Replace the static arrow icon with an IconButton for navigation
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.indigo),
                                onPressed: () async {
                                  // Retrieve supermarkets that belong to the route shown in this assignment
                                  final routeName = assignment['route'] ?? '';
                                  List<String> supermarkets = [];

                                  if (routeName.isNotEmpty) {
                                    final supermarketsQuery =
                                        await FirebaseFirestore.instance
                                            .collection('supermarkets')
                                            .where('route',
                                                isEqualTo: routeName)
                                            .get();

                                    supermarkets = supermarketsQuery.docs
                                        .map((doc) =>
                                            doc['name']?.toString() ?? '')
                                        .where((name) => name.isNotEmpty)
                                        .toList();
                                  }

                                  // Show the supermarkets for this assignment's route
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SupermarketsScreen(
                                        routeName: routeName,
                                        routeId: assignment['routeId'] ?? '',
                                        supermarkets: supermarkets,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.check,
                                    color: Colors.white, size: 18),
                                label: const Text('Accept'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  minimumSize: const Size(100, 36),
                                ),
                                onPressed: () {
                                  _showAssignmentActionDialog(
                                    context,
                                    index,
                                    accept: true,
                                  );
                                },
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.close,
                                    color: Colors.white, size: 18),
                                label: const Text('Decline'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  minimumSize: const Size(100, 36),
                                ),
                                onPressed: () {
                                  _showAssignmentActionDialog(
                                    context,
                                    index,
                                    accept: false,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build dashboard cards
  Widget _buildDashboardCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Map Firestore collection names to route names
  String? _mapCollectionToRouteName(String collectionName) {
    switch (collectionName) {
      case 'tasks_Kandy':
        return 'Kandy';
      case 'tasks_Colombo':
        return 'Colombo';
      case 'tasks_A\'pura':
        return 'Anuradhapura';
      case 'tasks_Jaffna':
        return 'Jaffna';
      case 'tasks_Negombo':
        return 'Negombo';
      case 'tasks_Galle':
        return 'Galle';
      case 'tasks_Gampaha':
        return 'Gampaha';
      // Add more cases as needed for your routes
      default:
        // Fallback: if collectionName starts with 'tasks_', use the rest as route name
        if (collectionName.startsWith('tasks_')) {
          return collectionName.replaceFirst('tasks_', '');
        }
        return null;
    }
  }

  void _showAssignmentActionDialog(BuildContext context, int index,
      {required bool accept}) {
    final assignment = _assignments[index];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(accept ? 'Accept Assignment' : 'Decline Assignment'),
          content: Text(
            accept
                ? 'Do you want to accept this assignment?'
                : 'Do you want to decline this assignment?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _handleAssignmentAction(index, accept, context);
              },
              child: Text(accept ? 'Accept' : 'Decline'),
            ),
          ],
        );
      },
    );
  }

  // Update _handleAssignmentAction to accept BuildContext and navigate after accept
  Future<void> _handleAssignmentAction(
      int index, bool accept, BuildContext context) async {
    final assignment = _assignments[index];
    try {
      // Find the assignment document in Firestore
      final query = await FirebaseFirestore.instance
          .collection('assignments')
          .where('vehicle', isEqualTo: assignment['vehicle'])
          .where('route', isEqualTo: assignment['route'])
          .where('assignedAt', isEqualTo: assignment['assignedAt'])
          .get();

      if (query.docs.isNotEmpty) {
        final docRef = query.docs.first.reference;
        await docRef.update({'status': accept ? 'accepted' : 'declined'});
        setState(() {
          if (!accept) {
            _assignments.removeAt(index); // Remove declined assignment from UI
          } else {
            _assignments[index]['status'] = 'accepted';
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              accept ? 'Assignment accepted.' : 'Assignment declined.',
            ),
          ),
        );
        if (accept) {
          // Navigate to RouteTasksScreen for the accepted route
          final routeName =
              _mapCollectionToRouteName(assignment['route'] ?? 'Unknown');
          if (routeName != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RouteTasksScreen(routeName: routeName),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error updating assignment status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update assignment status.'),
        ),
      );
    }
  }
}

class OngoingTab extends StatefulWidget {
  const OngoingTab({super.key});

  @override
  _OngoingTabState createState() => _OngoingTabState();
}

class _OngoingTabState extends State<OngoingTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _routes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoutesAndTasks();
  }

  Future<void> _fetchRoutesAndTasks() async {
    try {
      final querySnapshot = await _firestore.collection('routes').get();
      final List<Map<String, dynamic>> fetchedRoutes =
          querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'title': data['routeName'],
          'icon': Icons.location_on,
          'tasks': data['tasks'] ?? [],
        };
      }).toList();

      setState(() {
        _routes = fetchedRoutes;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching routes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose a Route',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _routes.length,
                    itemBuilder: (context, index) {
                      final route = _routes[index];
                      return GestureDetector(
                        onTap: () => _navigateToRouteDetails(context, route),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 6,
                          shadowColor: Colors.blue.shade100,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade50,
                                  Colors.blue.shade100
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  route['icon'],
                                  size: 40,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  route['title'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }

  void _navigateToRouteDetails(
      BuildContext context, Map<String, dynamic> route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RouteDetailsPage(route: route),
      ),
    );
  }
}

class RouteDetailsPage extends StatefulWidget {
  final Map<String, dynamic> route;

  const RouteDetailsPage({super.key, required this.route});

  @override
  _RouteDetailsPageState createState() => _RouteDetailsPageState();
}

class _RouteDetailsPageState extends State<RouteDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final route = widget.route;
    return Scaffold(
      appBar: AppBar(
        title: Text(route['title']),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: route['tasks'].length,
          itemBuilder: (context, taskIndex) {
            final task = route['tasks'][taskIndex];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: ListTile(
                leading: Checkbox(
                  value: task['completed'],
                  onChanged: task['completed']
                      ? null
                      : (value) => _markTaskAsCompleted(context, taskIndex),
                ),
                title: Text(
                  task['title'],
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    decoration:
                        task['completed'] ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: task['completed']
                    ? Text(
                        'Completed on: ${task['proof']}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.green,
                        ),
                      )
                    : null,
                trailing: IconButton(
                  icon: const Icon(Icons.info, color: Colors.blue),
                  onPressed: () => _showTaskInfo(context, task['info']),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _markTaskAsCompleted(BuildContext context, int taskIndex) {
    setState(() {
      final task = widget.route['tasks'][taskIndex];
      task['completed'] = true;
      task['proof'] =
          'Completed on ${DateFormat('yyyy-MM-dd hh:mm:ss a').format(DateTime.now())}';
    });
  }

  void _showTaskInfo(BuildContext context, Map<String, dynamic> info) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Task Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product: ${info['product']}'),
              Text('Quantity: ${info['quantity']}'),
              Text('Assigned By: ${info['assignedBy']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class MapTab extends StatefulWidget {
  @override
  _MapTabState createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  late GoogleMapController _mapController;
  LatLng _currentLocation =
      const LatLng(7.8731, 80.7718); // Default to Sri Lanka center
  bool _locationLoaded = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _locationLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if running on web and show fallback UI
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Map'),
          backgroundColor: Colors.blue,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map,
                size: 100,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              Text(
                'Map Feature',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Google Maps is not yet configured for web.\nPlease use the mobile app for full map functionality.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: _locationLoaded
          ? GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 8.0, // Adjust zoom level for Sri Lanka
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('currentLocation'),
                  position: _currentLocation,
                  infoWindow: const InfoWindow(title: 'You are here'),
                ),
              },
              onMapCreated: (controller) {
                _mapController = controller;
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class HelpSupportTab extends StatelessWidget {
  const HelpSupportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: const [
        ListTile(
          leading: Icon(Icons.phone, color: Colors.blue),
          title: Text('Phone'),
          subtitle: Text('+1234567890'),
        ),
        ListTile(
          leading: Icon(Icons.email, color: Colors.blue),
          title: Text('Email'),
          subtitle: Text('support@routex.com'),
        ),
        ListTile(
          leading: Icon(Icons.help_outline, color: Colors.blue),
          title: Text('FAQ'),
        ),
      ],
    );
  }
}

class EmergencyTab extends StatelessWidget {
  const EmergencyTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> emergencyContacts = [
      {
        'name': 'Police',
        'number': '119',
        'icon': Icons.local_police,
        'description': 'Contact the police for any law enforcement emergencies.'
      },
      {
        'name': 'Ambulance',
        'number': '1990',
        'icon': Icons.local_hospital,
        'description': 'Call an ambulance for medical emergencies.'
      },
      {
        'name': 'Fire Brigade',
        'number': '110',
        'icon': Icons.fire_truck,
        'description':
            'Reach out to the fire brigade for fire-related emergencies.'
      },
      {
        'name': 'Roadside Assistance',
        'number': '1980',
        'icon': Icons.car_repair,
        'description':
            'Get help for vehicle breakdowns or roadside emergencies.'
      },
      {
        'name': 'Admin',
        'number': '1980',
        'icon': Icons.contact_emergency,
        'description':
            'Inform admin regarding the emergency or any issues you face.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: emergencyContacts.length,
          itemBuilder: (context, index) {
            final contact = emergencyContacts[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: ListTile(
                leading: Icon(contact['icon'], color: Colors.red, size: 30),
                title: Text(
                  contact['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                subtitle: Text(
                  contact['description'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: Colors.grey,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.phone, color: Colors.green),
                  onPressed: () {
                    _makePhoneCall(contact['number']);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _makePhoneCall(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print('Could not launch $number');
    }
  }
}

class OverviewItem extends StatelessWidget {
  final String label;
  final String value;

  const OverviewItem({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

/// Helper to format Sri Lankan phone numbers for Firebase Auth.
/// Accepts numbers like '0712345678' or '712345678' and returns '+94712345678'.
String formatSriLankanPhoneNumber(String input) {
  String number = input.trim();
  if (number.startsWith('+94')) {
    return number;
  }
  if (number.startsWith('0')) {
    number = number.substring(1);
  }
  if (!number.startsWith('7')) {
    throw Exception('Invalid Sri Lankan mobile number');
  }
  return '+94$number';
}

class SupermarketsScreen extends StatelessWidget {
  final String routeName;
  final String routeId;
  final List<String> supermarkets;

  const SupermarketsScreen({
    super.key,
    required this.routeName,
    required this.routeId,
    required this.supermarkets,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$routeName Supermarkets'),
        backgroundColor: Colors.blue,
      ),
      body: supermarkets.isEmpty
          ? const Center(
              child: Text('No supermarkets assigned for this route.'))
          : ListView.builder(
              itemCount: supermarkets.length,
              itemBuilder: (context, index) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.store, color: Colors.indigo),
                    title: Text(supermarkets[index]),
                  ),
                );
              },
            ),
    );
  }
}
