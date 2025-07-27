import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_bottom_nav.dart';
import 'dashboard_screen.dart';
import 'attendance_marker_screen.dart';
import 'timetable_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;

  // Updated list of pages for the navigation bar
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    AttendanceMarkerScreen(), // This is now the main attendance/subject screen
    TimetableScreen(),
    ProfileScreen(),
  ];

  // Updated list of titles for the app bar
  static const List<String> _appBarTitles = <String>[
    'Dashboard',
    'Your Attendance', // Title for the new screen
    'Timetable',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // The AppBar is now conditional. It will not show on the "Your Attendance"
      // screen (index 1) because that screen has its own AppBar.
      appBar: _selectedIndex == 1
          ? null
          : AppBar(
              title: Text(_appBarTitles[_selectedIndex]),
              backgroundColor: const Color(0xFF1E293B),
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await _authService.signOut();
                  },
                  tooltip: 'Logout',
                ),
              ],
            ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: CustomBottomNav(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
