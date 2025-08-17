import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GuestOrdersScreen extends StatelessWidget {
  const GuestOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles & Facilities'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('vehicles').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No vehicles found.'));
          }
          final vehicles = snapshot.data!.docs;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vehicles.length,
            separatorBuilder: (context, index) => const SizedBox(height: 18),
            itemBuilder: (context, index) {
              final v = vehicles[index].data() as Map<String, dynamic>;
              // Split facilities by comma and trim spaces
              final facilities = (v['facilities'] ?? '')
                  .toString()
                  .split(',')
                  .map((f) => f.trim())
                  .where((f) => f.isNotEmpty)
                  .toList();

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.blue.shade100, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vehicle number and name
                      Row(
                        children: [
                          Icon(Icons.directions_car,
                              color: Colors.blue[700], size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              v['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              v['number'] ?? '-',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Facilities as chips
                      if (facilities.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: facilities
                                .map((f) => Chip(
                                      label: Text(
                                        f,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 13,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      backgroundColor: Colors.blue[50],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      if (facilities.isEmpty)
                        const Text(
                          'No facilities listed.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _VehicleSpec(
                              label: 'Width', value: v['width']?.toString()),
                          _VehicleSpec(
                              label: 'Height', value: v['height']?.toString()),
                          _VehicleSpec(
                              label: 'Length', value: v['length']?.toString()),
                          _VehicleSpec(
                              label: 'Weight', value: v['weight']?.toString()),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _VehicleSpec extends StatelessWidget {
  final String label;
  final String? value;

  const _VehicleSpec({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              value ?? '-',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
