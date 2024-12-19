import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'friend_event_list_page.dart';
import 'my_event_list.dart';
import 'notification_list.dart';
import 'profile.dart';

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
      upcomingEvents: 0, // Default value, will update later
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  late Stream<List<Friend>> _friendsStream;

  @override
  void initState() {
    super.initState();
    _friendsStream = _getFriendsStreamWithEventCounts();
  }

  // Fetch friends and their event counts
  Stream<List<Friend>> _getFriendsStreamWithEventCounts() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .collection('friends')
        .snapshots()
        .asyncMap((snapshot) async {
      // Fetch friends as a list of Friend objects
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

  // Fetch the event count for a specific friend
  Future<int> _getEventCountForFriend(String friendId) async {
    final query = await _firestore
        .collection('events')
        .where('userId', isEqualTo: friendId)
        .get();
    return query.docs.length;
  }

  // Add a friend to the current user's friend list in Firestore
  void _addFriend(String name, String uid) {
    _firestore.collection('users')
        .doc(currentUserUid)
        .collection('friends') // Store the friend in the 'friends' subcollection
        .doc(uid) // Use the friend's UID to store their info
        .set({
      'name': name,
      'avatar': 'default_avatar_url', // You can customize this based on the friend's data
      'upcomingEvents': 0, // Default value
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name added as a friend!')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Hedieaty',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontFamily: "Parkinsans",
              ),
            ),
            SizedBox(width: 10),
            Icon(
              Icons.card_giftcard,
              color: Colors.deepPurple,
              size: 35,
            ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications,
                  size: 30,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationScreen(currentUserId: currentUserUid), // Pass currentUserId
                    ),
                  );
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUserUid)
                    .collection('notifications')
                    .where('isRead', isEqualTo: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Container();
                  final newNotificationCount = snapshot.data!.docs.length;

                  // Show pop-up notification (SnackBar or Dialog) when a new notification is added
                  Future.delayed(Duration.zero, () {
                    if (newNotificationCount > 0) {
                      // Show a SnackBar or any custom popup
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$newNotificationCount new notifications'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  });

                  return Positioned(
                    right: 11,
                    top: 11,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '$newNotificationCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder<List<Friend>>(
            stream: _friendsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No friends added yet.'));
              }

              final friends = snapshot.data!;
              return ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: ListTile(
                      title: Text(
                        friend.name,
                        style: TextStyle(
                          fontFamily: "Parkinsans",
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        friend.upcomingEvents > 0
                            ? 'Upcoming Events: ${friend.upcomingEvents}'
                            : 'No Upcoming Events',
                        style: TextStyle(
                          fontFamily: "Parkinsans",
                          color: Colors.grey[700],
                        ),
                      ),
                      leading: CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage("asset/images/person icon.jpg"),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.deepPurple,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FEventListPage(friendName: friend.name, friendId: friend.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddFriendDialog(context);
        },
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Add a Friend',
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        currentIndex: 0, // Set the active tab index
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => EventListPage()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }



  // Function to show dialog for adding a friend
  void _showAddFriendDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a New Friend'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Enter friend\'s name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  // Find the user by name
                  _firestore.collection('users')
                      .where('name', isEqualTo: _controller.text)
                      .limit(1)
                      .get()
                      .then((querySnapshot) {
                    if (querySnapshot.docs.isNotEmpty) {
                      // Add the friend to the current user's friend list
                      final friendDoc = querySnapshot.docs.first;
                      _addFriend(_controller.text, friendDoc.id);
                      Navigator.pop(context); // Close the dialog
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('User not found')),
                      );
                    }
                  });
                }
              },
              child: Text('Add Friend'),
            ),
          ],
        );
      },
    );
  }
}
