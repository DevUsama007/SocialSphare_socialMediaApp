import 'package:cloud_firestore/cloud_firestore.dart';

class UserM {
  final String name;
  final String profileImageLink;
  final String username;
  final String userId;

  UserM(
      {required this.userId,
      required this.name,
      required this.username,
      required this.profileImageLink});

  factory UserM.fromDocument(DocumentSnapshot doc) {
    return UserM(
      name: doc['Name'],
      profileImageLink: doc['profile_image_link'],
      username: doc['user_name'],
      userId: doc['user_id'],
    
    );
  }
}
