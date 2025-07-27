import 'package:attendo_app/models/subject_model.dart';
import 'package:attendo_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class AttendanceMarkerScreen extends StatefulWidget {
  const AttendanceMarkerScreen({super.key});

  @override
  State<AttendanceMarkerScreen> createState() => _AttendanceMarkerScreenState();
}

class _AttendanceMarkerScreenState extends State<AttendanceMarkerScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  void _showAddSubjectDialog() {
    final nameController = TextEditingController();
    final staffController = TextEditingController();
    final percentageController = TextEditingController(text: '75');
    final formKey = GlobalKey<FormState>();
    final List<String> daysOfWeek = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    final List<String> selectedDays = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: const Text('Add New Subject', style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Subject Name'),
                      ),
                      TextFormField(
                        controller: staffController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Staff Name'),
                      ),
                      TextFormField(
                        controller: percentageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Required Percentage (%)'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Cannot be empty';
                          if (double.tryParse(value) == null) return 'Enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text("Select Days:", style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: daysOfWeek.map((day) {
                          final isSelected = selectedDays.contains(day);
                          return FilterChip(
                            label: Text(day),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setDialogState(() {
                                if (selected) {
                                  selectedDays.add(day);
                                } else {
                                  selectedDays.remove(day);
                                }
                              });
                            },
                            backgroundColor: Colors.white24,
                            selectedColor: Colors.cyanAccent,
                            labelStyle: const TextStyle(color: Colors.black),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final requiredPercentage = double.parse(percentageController.text);
                      _firestoreService.addSubject(
                        nameController.text,
                        staffController.text,
                        currentUser!.uid,
                        requiredPercentage,
                        selectedDays,
                      );
                      Navigator.of(context).pop();
                      showToast('Subject Added!');
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) return const Center(child: Text("Please log in."));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Your Attendance"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            onPressed: _showAddSubjectDialog,
            tooltip: 'Add Subject',
          ),
        ],
      ),
      body: StreamBuilder<List<Subject>>(
        stream: _firestoreService.getSubjects(currentUser!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No subjects found. Add one to start.", style: TextStyle(color: Colors.white70)),
            );
          }

          final subjects = snapshot.data!;
          return SafeArea(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                12.0,
                12.0,
                12.0,
                MediaQuery.of(context).padding.bottom + 80.0,
              ),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                return _buildSubjectCard(subject);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubjectCard(Subject subject) {
    final totalClasses = subject.attended + subject.missed;
    final percentage = totalClasses == 0 ? 0.0 : subject.attended / totalClasses;
    final requiredClasses = (totalClasses * (subject.requiredPercentage / 100)).ceil();
    final skippableClasses = subject.attended - requiredClasses;

    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(subject.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Text("Attended: ${subject.attended}", style: const TextStyle(color: Colors.white70)),
                      Text("Missed: ${subject.missed}", style: const TextStyle(color: Colors.white70)),
                      Text("Total: $totalClasses", style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text(
                        skippableClasses >= 0
                            ? "Can skip next $skippableClasses"
                            : "Cannot skip",
                        style: TextStyle(
                          color: skippableClasses >= 0 ? Colors.greenAccent : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularPercentIndicator(
                    radius: 45.0,
                    lineWidth: 8.0,
                    percent: percentage.clamp(0.0, 1.0),
                    center: FittedBox(
                      child: Text(
                        "${(percentage * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    progressColor: percentage >= (subject.requiredPercentage / 100)
                        ? Colors.green
                        : Colors.orange,
                    backgroundColor: Colors.white.withAlpha(50),
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 400) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Text("Attended ", style: TextStyle(color: Colors.white70)),
                        _buildIncrementButton(
                          icon: Icons.remove,
                          onPressed: subject.attended > 0
                              ? () => _firestoreService.updateAttendance(subjectId: subject.id, attendedIncrement: -1)
                              : null,
                        ),
                        _buildIncrementButton(
                          icon: Icons.add,
                          onPressed: () => _firestoreService.updateAttendance(subjectId: subject.id, attendedIncrement: 1),
                        ),
                      ]),
                      TextButton(
                        onPressed: () => _firestoreService.deleteSubject(subject.id),
                        child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
                      ),
                      Row(children: [
                        const Text("Missed ", style: TextStyle(color: Colors.white70)),
                        _buildIncrementButton(
                          icon: Icons.remove,
                          onPressed: subject.missed > 0
                              ? () => _firestoreService.updateAttendance(subjectId: subject.id, missedIncrement: -1)
                              : null,
                        ),
                        _buildIncrementButton(
                          icon: Icons.add,
                          onPressed: () => _firestoreService.updateAttendance(subjectId: subject.id, missedIncrement: 1),
                        ),
                      ]),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Row(children: [
                        const Text("Attended ", style: TextStyle(color: Colors.white70)),
                        _buildIncrementButton(
                          icon: Icons.remove,
                          onPressed: subject.attended > 0
                              ? () => _firestoreService.updateAttendance(subjectId: subject.id, attendedIncrement: -1)
                              : null,
                        ),
                        _buildIncrementButton(
                          icon: Icons.add,
                          onPressed: () => _firestoreService.updateAttendance(subjectId: subject.id, attendedIncrement: 1),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Text("Missed ", style: TextStyle(color: Colors.white70)),
                        _buildIncrementButton(
                          icon: Icons.remove,
                          onPressed: subject.missed > 0
                              ? () => _firestoreService.updateAttendance(subjectId: subject.id, missedIncrement: -1)
                              : null,
                        ),
                        _buildIncrementButton(
                          icon: Icons.add,
                          onPressed: () => _firestoreService.updateAttendance(subjectId: subject.id, missedIncrement: 1),
                        ),
                      ]),
                      TextButton(
                        onPressed: () => _firestoreService.deleteSubject(subject.id),
                        child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIncrementButton({required IconData icon, required VoidCallback? onPressed}) {
    return InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: onPressed != null ? Colors.white54 : Colors.transparent, width: 1),
        ),
        child: Icon(icon, color: onPressed != null ? Colors.white : Colors.white24, size: 20),
      ),
    );
  }
}
