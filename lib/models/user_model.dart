class UserModel {
  final String uid;
  final String email;
  final String name;
  final String type; // "student" or "faculty"
  final String? profileImageUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.type,
    this.profileImageUrl,
  });

  // Function to convert a UserModel instance to a map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'type': type,
      'profileImageUrl': profileImageUrl,
    };
  }
  // NEW: Factory constructor to create a UserModel from a map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? 'No Name',
      type: map['type'] ?? 'student',
      profileImageUrl: map['profileImageUrl'],
    );
  }
}
