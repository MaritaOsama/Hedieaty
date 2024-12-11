import 'package:flutter/material.dart';
import 'package:hedieaty/screens/friend_event_list_page.dart';
import 'friend_gift_list.dart';
import 'my_event_list.dart';
import 'my_gift_list.dart';

class Friend {
  final String name;
  final String avatar;
  final int upcomingEvents;

  Friend({required this.name, required this.avatar, required this.upcomingEvents});
}

class HomePage extends StatelessWidget {
  final List<Friend> friends = [
    Friend(name: 'Alice', avatar: 'asset/Female_Icon (2).png', upcomingEvents: 1),
    Friend(name: 'Bob', avatar: 'asset/Male_Icon.png', upcomingEvents: 2),
    Friend(name: 'Charlie', avatar: 'asset/Male_Icon.png', upcomingEvents: 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
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
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              size: 30,
            ),
            onPressed: () {
              // search logic goes here
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return ListTile(
            title: Text(friend.name,
            style: TextStyle(
              fontFamily: "Parkinsans"
            ),),
            subtitle: Text(friend.upcomingEvents > 0
                ? 'Upcoming Events: ${friend.upcomingEvents}'
                : 'No Upcoming Events'),
            leading: CircleAvatar(
              backgroundImage: AssetImage(friend.avatar),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FEventListPage(friendName: friend.name),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/events');
        },
        child: Icon(Icons.add),
        tooltip: 'Create an Event',
      ),
      bottomNavigationBar: BottomNavigationBar(
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
                MaterialPageRoute(builder: (context) => GiftListPage(friendName: 'Friend Placeholder')),
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
            icon: Icon(Icons.card_giftcard),
            label: 'Gifts',
          ),
        ],
      ),
    );
  }
}
