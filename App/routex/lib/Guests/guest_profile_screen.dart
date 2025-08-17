import 'package:flutter/material.dart';
import 'package:routex/Guests/guest_home_screen.dart';
import 'package:routex/Guests/guest_activities_screen.dart';
import 'package:routex/Guests/guest_settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class GuestProfileScreen extends StatefulWidget {
  const GuestProfileScreen({super.key});

  @override
  State<GuestProfileScreen> createState() => _GuestProfileScreenState();
}

class _GuestProfileScreenState extends State<GuestProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _userName;
  String? _email;
  String? _mobile;
  String? _photoUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('guest_profile')
          .doc(user.uid)
          .get();
      final data = doc.data() ?? {};
      setState(() {
        _userName = data['name'] ?? user.displayName ?? '';
        _email = data['email'] ?? user.email ?? '';
        _mobile = data['mobile'] ?? '';
        _photoUrl = data['photoUrl'] ?? user.photoURL;
      });
    }
  }

  Future<void> _pickImage() async {
    final user = FirebaseAuth.instance.currentUser;
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null && user != null) {
      try {
        final storageRef = FirebaseStorage.instance.ref().child(
            'guest_profile_pictures/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
        final bytes = await picked.readAsBytes();
        if (bytes.isNotEmpty) {
          await storageRef.putData(bytes);
          final url = await storageRef.getDownloadURL();
          await FirebaseFirestore.instance
              .collection('guest_profile')
              .doc(user.uid)
              .set({'photoUrl': url}, SetOptions(merge: true));
          await user.updatePhotoURL(url);
          setState(() {
            _photoUrl = url;
          });
        }
      } on FirebaseException catch (e) {
        if (e.code == 'unauthorized') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'You are not authorized to upload images. Please check your Firebase Storage rules.'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image upload failed: ${e.message}')),
          );
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('guest_profile')
          .doc(user.uid)
          .set({
        'name': _userName,
        'email': _email,
        'mobile': _mobile,
        'photoUrl': _photoUrl,
      }, SetOptions(merge: true));
      // Optionally update FirebaseAuth displayName and photoURL
      await user.updateDisplayName(_userName);
      if (_photoUrl != null && _photoUrl!.isNotEmpty) {
        await user.updatePhotoURL(_photoUrl);
      }
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      // Update the home screen welcome message if open
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GuestProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int selectedIndex = 1; // Profile tab

    void onTabTapped(int index) {
      if (index == selectedIndex) return;
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const GuestHomeScreen()),
          );
          break;
        case 1:
          // Already on Profile
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
      ),
      body: _userName == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Force CircleAvatar to rebuild with the latest _photoUrl
                        Builder(
                          builder: (context) {
                            final photo = _photoUrl;
                            return Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 45,
                                  backgroundColor: Colors.blue[50],
                                  backgroundImage:
                                      (photo != null && photo.isNotEmpty)
                                          ? NetworkImage(photo)
                                          : null,
                                  child: (photo == null || photo.isEmpty)
                                      ? const Icon(Icons.person,
                                          size: 60, color: Colors.blue)
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: const Icon(Icons.camera_alt,
                                          color: Colors.white, size: 20),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          initialValue: _userName,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? 'Enter your name'
                              : null,
                          onSaved: (val) => _userName = val,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _email,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? 'Enter your email'
                              : null,
                          onSaved: (val) => _email = val,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _mobile,
                          decoration: const InputDecoration(
                            labelText: 'Mobile',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? 'Enter your mobile'
                              : null,
                          onSaved: (val) => _mobile = val,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveProfile,
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Save'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
