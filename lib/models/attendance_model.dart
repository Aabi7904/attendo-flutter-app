import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String id;
  final String subjectId;
  final String userId;
  final DateTime date;
  final String status; // e.g., "present", "absent", "skipped"

  AttendanceRecord({
    required this.id,
    required this.subjectId,
    required this.userId,
    required this.date,
    required this.status,
  });

  // Convert an AttendanceRecord object into a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'subjectId': subjectId,
      'userId': userId,
      'date': Timestamp.fromDate(date), // Store date as Firestore Timestamp
      'status': status,
    };
  }

  // Create an AttendanceRecord object from a Firestore document
  factory AttendanceRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AttendanceRecord(
      id: doc.id,
      subjectId: data['subjectId'] ?? '',
      userId: data['userId'] ?? '',
      // Convert Firestore Timestamp back to DateTime
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'absent',
    );
  }
}
