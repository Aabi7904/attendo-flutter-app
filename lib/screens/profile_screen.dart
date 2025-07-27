import 'package:attendo_app/models/user_model.dart';
import 'package:attendo_app/services/auth_service.dart';
import 'package:attendo_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text("Not logged in."));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<UserModel?>(
        future: _firestoreService.getUser(currentUser!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Could not load profile."));
          }

          final user = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileAvatar(user),
                const SizedBox(height: 24),
                Text(
                  user.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white70),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text("LOGOUT"),
                  onPressed: () async {
                    await _authService.signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.redAccent.withAlpha(150),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 80), // Padding for the bottom nav bar
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileAvatar(UserModel user) {
    // Use the user's photoURL if available (from Google Sign-In)
    final photoUrl = user.profileImageUrl;
    // Otherwise, use the first letter of their name as an initial
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.cyanAccent,
      // Use a network image if URL exists, otherwise show the initial
      backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
      child: photoUrl == null
          ? Text(
              initial,
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            )
          : null,
    );
  }
}
