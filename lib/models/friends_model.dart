import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  final String id;
  final String name;
  final String avatar;
  final int upcomingEvents;

  Friend({
    required this.id,
    required this.name,
    required this.avatar,
    required this.upcomingEvents,
  });

  factory Friend.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Friend(
      id: doc.id,
      name: data['name'] ?? '',
      avatar: data['avatar'] ?? '',
      upcomingEvents: 0,
    );
  }
}
