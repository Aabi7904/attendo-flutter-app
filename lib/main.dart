import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oktoast/oktoast.dart';

// Import your screen files (which we will create next)
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

// Make sure you have a firebase_options.dart file from your FlutterFire setup
import 'firebase_options.dart';

Future<void> main() async {
  // Ensure Flutter widgets are initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(OKToast(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      debugShowCheckedModeBanner: false,
      // Set the dark theme with a neon/glassmorphic feel
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // A dark blue-slate color
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      // The AuthGate will decide which screen to show
      home: const AuthGate(),
    );
  }
}

// This widget will listen to auth changes
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listen to the user's authentication state
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the snapshot has no data, it means the user is not logged in
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // If the user is logged in, show the home screen
        return const HomeScreen();
      },
    );
  }
}