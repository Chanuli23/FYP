import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RouteTasksScreen extends StatefulWidget {
  final String routeName;

  const RouteTasksScreen({required this.routeName, super.key});

  @override
  _RouteTasksScreenState createState() => _RouteTasksScreenState();
}

class _RouteTasksScreenState extends State<RouteTasksScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Removed unused ImagePicker field

  @override
  Widget build(BuildContext context) {
    return widget.routeName != "Routes"
        ? _buildTasksScreen()
        : _buildRoutesGrid();
  }

  Widget _buildRoutesGrid() {
    final List<Map<String, dynamic>> routes = [
      {'title': 'Jaffna', 'icon': Icons.location_on},
      {'title': 'Galle', 'icon': Icons.location_on},
      {'title': 'Negombo', 'icon': Icons.location_on},
      {'title': 'Colombo', 'icon': Icons.location_on},
      {'title': 'Anuradhapura', 'icon': Icons.location_on},
      {'title': 'Kandy', 'icon': Icons.location_on},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Route',
            style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.2,
          ),
          itemCount: routes.length,
          itemBuilder: (context, index) {
            final route = routes[index];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RouteTasksScreen(routeName: route['title']),
                ),
              ),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 6,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.blue.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(route['icon'],
                          size: 40, color: Colors.blue.shade700),
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
    );
  }

  Widget _buildTasksScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.routeName} Route',
            style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getTasksForRoute(widget.routeName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading tasks: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final tasks = snapshot.data ?? [];
          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                'No tasks available for this route',
                style: TextStyle(fontSize: 18, fontFamily: 'Poppins'),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 6,
                child: ListTile(
                  leading: Icon(
                    task['completed'] == true
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color:
                        task['completed'] == true ? Colors.green : Colors.grey,
                    size: 30,
                  ),
                  title: Text(
                    task['title'] ?? 'Unnamed Task',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      decoration: task['completed'] == true
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Description: ${task['description'] ?? 'No description'}'),
                      Text(
                          'Created At: ${_formatTimestamp(task['createdAt'])}'),
                      Text('Due Date: ${_formatDate(task['dueDate'])}'),
                      if (task['completedAt'] != null)
                        Text(
                            'Completed At: ${_formatTimestamp(task['completedAt'])}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.info, color: Colors.blue),
                    onPressed: () => _showTaskDetails(task),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getTasksForRoute(String routeName) async {
    final collectionName = _getCollectionName(routeName);
    if (collectionName.isEmpty) return [];

    try {
      final querySnapshot = await _firestore.collection(collectionName).get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? 'Unnamed Task',
          'description': data['description'] ?? 'No description available',
          'createdAt': data['createdAt'],
          'dueDate': data['dueDate'],
          'completedAt': data['completedAt'],
          'completed': data['completed'] ?? false,
        };
      }).toList();
    } catch (e) {
      print('Error fetching tasks for $routeName: $e');
      return [];
    }
  }

  String _getCollectionName(String routeName) {
    switch (routeName) {
      case 'Jaffna':
        return 'tasks_Jaffna';
      case 'Galle':
        return 'tasks_Galle';
      case 'Negombo':
        return 'tasks_Negombo';
      case 'Colombo':
        return 'tasks_Colombo';
      case 'Anuradhapura':
        return 'tasks_A\'pura';
      case 'Kandy':
        return 'tasks_Kandy';
      default:
        return '';
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';

    try {
      if (timestamp is Timestamp) {
        // Firestore Timestamp
        return DateFormat('yyyy-MM-dd hh:mm a').format(timestamp.toDate());
      } else if (timestamp is String) {
        // ISO 8601 String
        final parsedDate = DateTime.parse(timestamp);
        return DateFormat('yyyy-MM-dd hh:mm a').format(parsedDate);
      } else if (timestamp is DateTime) {
        // DateTime object
        return DateFormat('yyyy-MM-dd hh:mm a').format(timestamp);
      }
    } catch (e) {
      print('Error formatting timestamp: $e');
    }

    return 'Invalid format';
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';

    try {
      if (date is String) {
        // ISO 8601 String
        final parsedDate = DateTime.parse(date);
        return DateFormat('yyyy-MM-dd').format(parsedDate);
      } else if (date is DateTime) {
        // DateTime object
        return DateFormat('yyyy-MM-dd').format(date);
      }
    } catch (e) {
      print('Error formatting date: $e');
    }

    return 'Invalid format';
  }

  void _showTaskDetails(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(task['title'] ?? 'Task Details',
              style: const TextStyle(fontFamily: 'Poppins')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Description: ${task['description'] ?? 'No description'}'),
              Text('Created At: ${_formatTimestamp(task['createdAt'])}'),
              Text('Due Date: ${_formatDate(task['dueDate'])}'),
              if (task['completedAt'] != null)
                Text('Completed At: ${_formatTimestamp(task['completedAt'])}'),
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
