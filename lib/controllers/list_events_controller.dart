import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty/models/list_events_model.dart';

class EventController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Event>> fetchEvents() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is logged in!');
    }

    QuerySnapshot snapshot = await _firestore
        .collection('events')
        .where('userId', isEqualTo: user.uid)
        .get();

    return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
  }

  Future<void> saveEvent(Event event) async {
    await _firestore.collection('events').add({
      'name': event.name,
      'category': event.category,
      'date': event.date,
      'status': event.status,
      'userId': event.userId,
    });
  }

  Future<void> sendEventNotifications(String userId, String eventName) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userName = userDoc.data()?['name'];

    if (userName != null) {
      final friendsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .get();

      for (var friendDoc in friendsSnapshot.docs) {
        final friendId = friendDoc.id;

        await _firestore
            .collection('users')
            .doc(friendId)
            .collection('notifications')
            .add({
          'title': 'New Event Created',
          'type': 'event_created',
          'message': '$userName has created a new event: $eventName.',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }
    }
  }
}
