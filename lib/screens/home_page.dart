import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'friend_gift_list.dart';
import 'my_event_list.dart';
import 'my_gift_list.dart';
import 'friend_event_list_page.dart';
import 'package:hedieaty/screens/profile.dart';

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
      upcomingEvents: data['upcomingEvents'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatar': avatar,
      'upcomingEvents': upcomingEvents,
    };
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
    _friendsStream = _getFriendsStream();
  }

  // Fetch the friends data for the current user
  Stream<List<Friend>> _getFriendsStream() {
    return FirebaseFirestore.instance
        .collection('users') // Ensure this matches the collection you're using
        .doc(currentUserUid) // Get the current user
        .collection('friends') // Subcollection of friends for the current user
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Friend.fromFirestore(doc)).toList());
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
          IconButton(
            icon: Icon(
              Icons.search,
              size: 30,
              color: Colors.white,
            ),
            onPressed: () {
              // Search logic goes here
            },
          )
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
                      backgroundImage: friend.avatar.startsWith('http')
                          ? NetworkImage(friend.avatar)
                          : AssetImage(friend.avatar) as ImageProvider,
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
                              FEventListPage(friendName: friend.name),
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