import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subject_model.dart';
import '../models/user_model.dart';
import 'dart:developer';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ... (getUser and setUser methods are unchanged)
  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      log("Error getting user: $e");
      return null;
    }
  }
  Future<void> setUser(UserModel user) async {
    final options = SetOptions(merge: true);
    return _db.collection('users').doc(user.uid).set(user.toMap(), options);
  }


  // --- SUBJECT & ATTENDANCE METHODS ---
  Stream<List<Subject>> getSubjects(String userId) {
    return _db
        .collection('subjects')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Subject.fromFirestore(doc))
            .toList());
  }

  // UPDATED: addSubject now includes the timetable
  Future<void> addSubject(String name, String staffName, String userId, double requiredPercentage, List<String> timetable) {
    final newSubject = Subject(
      id: '',
      name: name,
      staffName: staffName,
      userId: userId,
      attended: 0,
      missed: 0,
      requiredPercentage: requiredPercentage,
      timetable: timetable,
    );
    return _db.collection('subjects').add(newSubject.toMap());
  }
  
  // NEW: Get subjects for a specific day
  Stream<List<Subject>> getSubjectsForDay(String userId, String day) {
    return _db
        .collection('subjects')
        .where('userId', isEqualTo: userId)
        .where('timetable', arrayContains: day)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Subject.fromFirestore(doc))
            .toList());
  }

  Future<void> updateAttendance(
      {required String subjectId, int attendedIncrement = 0, int missedIncrement = 0}) {
    return _db.collection('subjects').doc(subjectId).update({
      'attended': FieldValue.increment(attendedIncrement),
      'missed': FieldValue.increment(missedIncrement),
    });
  }

  Future<void> deleteSubject(String subjectId) {
    return _db.collection('subjects').doc(subjectId).delete();
  }
}
