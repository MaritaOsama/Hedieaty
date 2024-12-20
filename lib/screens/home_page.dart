// home_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/friends_model.dart';
import '/controllers/friends_controller.dart';
import 'friend_event_list_page.dart';
import 'my_event_list.dart';
import 'notification_list.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FriendController _friendController;
  late Stream<List<Friend>> _friendsStream;
  final String currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _friendController = FriendController(currentUserUid);
    _friendsStream = _friendController.getFriendsStreamWithEventCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
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
                return _buildFriendTile(friend);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFriendDialog(context),
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Add a Friend',
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
          Icon(Icons.card_giftcard, color: Colors.deepPurple, size: 35),
        ],
      ),
      backgroundColor: Colors.blueAccent,
      centerTitle: true,
      actions: [_buildNotificationIcon()],
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications, size: 30, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NotificationScreen(currentUserId: currentUserUid),
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
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container();
            }
            return Positioned(
              right: 11,
              top: 11,
              child: _buildNotificationBadge(snapshot.data!.docs.length),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationBadge(int count) {
    return Container(
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(6),
      ),
      constraints: BoxConstraints(minWidth: 12, minHeight: 12),
      child: Text(
        '$count',
        style: TextStyle(color: Colors.white, fontSize: 8),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFriendTile(Friend friend) {
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
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
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
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
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
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Events',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

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
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _friendController
                      .addFriend(_controller.text, currentUserUid)
                      .then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${_controller.text} added as a friend!')),
                    );
                    Navigator.pop(context);
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
