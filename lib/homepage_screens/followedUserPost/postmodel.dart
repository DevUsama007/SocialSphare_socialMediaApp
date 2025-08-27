import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String caption;
  final String postID;
  final String postType;
  final String postUrl;
  final DateTime timestamp;
  final String userID;
  final String username;
  final String name;
  final String userprofileImage;

  Post({
    required this.caption,
    required this.postID,
    required this.postType,
    required this.postUrl,
    required this.timestamp,
    required this.userID,
    required this.username,
    required this.name,
    required this.userprofileImage,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      caption: data['caption'] ?? '',
      name: data['name'] ?? '',
      postID: data['postID'] ?? '',
      postType: data['postType'] ?? '',
      postUrl: data['postUrl'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userID: data['userID'] ?? '',
      username: data['username'] ?? '',
      userprofileImage: data['userprofileImage'] ?? '',
    );
  }

}
