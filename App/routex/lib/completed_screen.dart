// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompletedScreen extends StatelessWidget {
  final CollectionReference _completedTasksCollection =
      FirebaseFirestore.instance.collection('completed_tasks');

  Future<List<DocumentSnapshot>> getCompletedTasks() async {
    final querySnapshot = await _completedTasksCollection
        .orderBy('completionDateTime', descending: true)
        .get();
    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Tasks'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<DocumentSnapshot>>(
          future: getCompletedTasks(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final completedTasks = snapshot.data!;
            if (completedTasks.isEmpty) {
              return const Center(child: Text('No completed tasks.'));
            }
            return ListView.builder(
              itemCount: completedTasks.length,
              itemBuilder: (context, index) {
                final task = completedTasks[index];
                return ListTile(
                  title: Text(task['task']),
                  subtitle: Text(
                    'Completed: ${task['completionDateTime'].toDate()}',
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
