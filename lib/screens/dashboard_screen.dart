import 'package:attendo_app/models/subject_model.dart';
import 'package:attendo_app/models/user_model.dart';
import 'package:attendo_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = userSnapshot.data!;

          return StreamBuilder<List<Subject>>(
            stream: _firestoreService.getSubjects(currentUser!.uid),
            builder: (context, subjectSnapshot) {
              if (!subjectSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final subjects = subjectSnapshot.data ?? [];
              final totalSubjects = subjects.length;

              // --- UPDATED CALCULATIONS ---
              final totalAttended = subjects.fold(0, (sum, item) => sum + item.attended);
              final totalMissed = subjects.fold(0, (sum, item) => sum + item.missed);
              final totalClasses = totalAttended + totalMissed;
              
              final overallPercentage = totalClasses > 0 ? totalAttended / totalClasses : 0.0;
              
              // Calculate total skippable classes by summing them up from each subject
              int totalSkippableClasses = 0;
              for (var subject in subjects) {
                final totalForSubject = subject.attended + subject.missed;
                if (totalForSubject > 0) {
                  final requiredForSubject = (totalForSubject * (subject.requiredPercentage / 100)).ceil();
                  final skippableForSubject = subject.attended - requiredForSubject;
                  if (skippableForSubject > 0) {
                    totalSkippableClasses += skippableForSubject;
                  }
                }
              }

              return _buildDashboardContent(
                user.name,
                totalSubjects,
                overallPercentage,
                totalSkippableClasses,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDashboardContent(
    String userName,
    int totalSubjects,
    double attendancePercentage,
    int skippableClasses,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          Text(
            "Hello,",
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Colors.white70),
          ),
          Text(
            userName,
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // Attendance Summary Card
          _buildAttendanceCard(attendancePercentage),
          const SizedBox(height: 24),
          // Other Stats
          Row(
            children: [
              Expanded(
                  child: _buildStatCard(
                      "Total Subjects", totalSubjects.toString(), Icons.book, Colors.orange)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildStatCard("Can Skip", skippableClasses.toString(),
                      Icons.directions_run, Colors.green)),
            ],
          ),
        ].animate(interval: 100.ms).slideY(begin: 0.2, curve: Curves.easeOut).fadeIn(),
      ),
    );
  }

  Widget _buildAttendanceCard(double percentage) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withAlpha(100),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Overall Attendance",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "Keep it up!",
                style: TextStyle(color: Colors.white.withAlpha(200)),
              ),
            ],
          ),
          CircularPercentIndicator(
            radius: 45.0,
            lineWidth: 8.0,
            percent: percentage,
            center: Text(
              "${(percentage * 100).toStringAsFixed(0)}%",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            progressColor: Colors.cyanAccent,
            backgroundColor: Colors.white.withAlpha(50),
            circularStrokeCap: CircularStrokeCap.round,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withAlpha(50),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: Colors.white.withAlpha(180)),
          ),
        ],
      ),
    );
  }
}
