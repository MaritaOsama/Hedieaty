import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String id;
  String name;
  String category;
  DateTime date;
  String status;
  String userId;

  Event({
    required this.id,
    required this.name,
    required this.category,
    required this.date,
    required this.userId,
  }) : status = _determineStatus(date);

  static String _determineStatus(DateTime date) {
    final now = DateTime.now();
    if (date.isAfter(now)) {
      return "Upcoming";
    } else if (date.isBefore(now)) {
      return "Past";
    } else {
      return "Current";
    }
  }

  // Create an Event object from Firestore data
  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      name: data['name'],
      category: data['category'],
      date: (data['date'] as Timestamp).toDate(),
      userId: data['userId'],
    );
  }
}
