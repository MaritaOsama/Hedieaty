// friend_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/models/friends_model.dart';

class FriendController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserUid;

  FriendController(this.currentUserUid);

  Stream<List<Friend>> getFriendsStreamWithEventCounts() {
    return _firestore
        .collection('users')
        .doc(currentUserUid)
        .collection('friends')
        .snapshots()
        .asyncMap((snapshot) async {
      final friends = await Future.wait(snapshot.docs.map((doc) async {
        final friend = Friend.fromFirestore(doc);
        final eventCount = await _getEventCountForFriend(friend.id);
        return Friend(
          id: friend.id,
          name: friend.name,
          avatar: friend.avatar,
          upcomingEvents: eventCount,
        );
      }).toList());

      return friends;
    });
  }

  Future<int> _getEventCountForFriend(String friendId) async {
    final query = await _firestore
        .collection('events')
        .where('userId', isEqualTo: friendId)
        .get();
    return query.docs.length;
  }

  Future<void> addFriend(String name, String uid) async {
    await _firestore
        .collection('users')
        .doc(currentUserUid)
        .collection('friends')
        .doc(uid)
        .set({
      'name': name,
      'avatar': 'default_avatar_url', // You can customize this
      'upcomingEvents': 0, // Default value
    });
  }
}
