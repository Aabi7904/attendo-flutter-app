import 'package:attendo_app/models/subject_model.dart';
import 'package:attendo_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _days.length, vsync: this);

    int todayIndex = DateTime.now().weekday - 1;
    if (todayIndex > 5) {
      todayIndex = 0;
    }
    _tabController.index = todayIndex;
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.cyanAccent,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.cyanAccent,
        tabs: _days.map((day) => Tab(text: day.toUpperCase())).toList(),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _days.map((day) => _buildDayView(day)).toList(),
      ),
    );
  }

  Widget _buildDayView(String day) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Center(child: Text("Not logged in."));

    final FirestoreService firestoreService = FirestoreService();

    return StreamBuilder<List<Subject>>(
      stream: firestoreService.getSubjectsForDay(currentUser.uid, day),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              "No classes scheduled for $day.",
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
          );
        }
        final subjects = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 90.0), // ✅ FIX ADDED HERE
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final subject = subjects[index];
            return Card(
              color: const Color(0xFF1E293B),
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                title: Text(subject.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(subject.staffName, style: const TextStyle(color: Colors.white70)),
              ),
            );
          },
        );
      },
    );
  }
}
