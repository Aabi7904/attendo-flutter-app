import 'package:cloud_firestore/cloud_firestore.dart';

class Subject {
  final String id;
  final String name;
  final String staffName;
  final String userId;
  final int attended;
  final int missed;
  final double requiredPercentage;
  final List<String> timetable; // NEW: e.g., ['Monday', 'Wednesday']

  Subject({
    required this.id,
    required this.name,
    required this.staffName,
    required this.userId,
    required this.attended,
    required this.missed,
    required this.requiredPercentage,
    required this.timetable,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'staffName': staffName,
      'userId': userId,
      'attended': attended,
      'missed': missed,
      'requiredPercentage': requiredPercentage,
      'timetable': timetable,
    };
  }

  factory Subject.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Subject(
      id: doc.id,
      name: data['name'] ?? 'No Name',
      staffName: data['staffName'] ?? 'No Staff',
      userId: data['userId'] ?? '',
      attended: data['attended'] ?? 0,
      missed: data['missed'] ?? 0,
      requiredPercentage: (data['requiredPercentage'] ?? 75.0).toDouble(),
      // Convert the dynamic list from Firestore to a list of strings
      timetable: List<String>.from(data['timetable'] ?? []),
    );
  }
}
