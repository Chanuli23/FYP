// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final LatLng _initialLocation =
      const LatLng(7.8731, 80.7718); // Default to Sri Lanka center
  LatLng? _currentLocation;
  bool _locationLoaded = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose(); // Dispose of the map controller
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied.');
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _locationLoaded = true;
      });

      // Move the camera to the current location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(_currentLocation!),
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor: Colors.blue,
      ),
      body: _locationLoaded
          ? GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation ?? _initialLocation,
                zoom: 12.0, // Adjust zoom level
              ),
              markers: {
                if (_currentLocation != null)
                  Marker(
                    markerId: const MarkerId('currentLocation'),
                    position: _currentLocation!,
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
