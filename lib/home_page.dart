import 'package:flutter/material.dart';
import 'gift_list.dart';
import 'event_list.dart';

class Friend {
  final String name;
  final String avatar;
  final int upcomingEvents;

  Friend({required this.name, required this.avatar, required this.upcomingEvents});
}


class HomePage extends StatelessWidget{
  final List<Friend> friends = [
    Friend(name: 'Alice', avatar: 'asset/Female_Icon (2).png', upcomingEvents: 1),
    Friend(name: 'Bob', avatar: 'asset/Male_Icon.png', upcomingEvents: 2),
    Friend(name: 'Charlie', avatar: 'asset/Male_Icon.png', upcomingEvents: 0),
  ];


  @override
  Widget build(BuildContext context){
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
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.card_giftcard,
                color: Colors.deepPurple,
                size: 35,),
          ],
        ),
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search,
            size: 30,),
            onPressed: () {
              // search logic goes here
            },
          )
        ],
        // Ensuring title remains centered
      ),
      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return ListTile(
            title: Text(friend.name),  // Friend's name is shown here
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
                  builder: (context) => GiftListPage(friendName: friend.name), // Pass the name directly
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
    );
  }
}

//try to commit