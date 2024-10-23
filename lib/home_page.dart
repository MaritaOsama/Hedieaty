import 'package:flutter/material.dart';

class HomePage extends StatelessWidget{
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
      body: Column(
        children: [
          ListTile(
            title: Text("Friend's Name"),
            subtitle: Text("Upcoming Events: 1"),
            leading: CircleAvatar(
              backgroundImage: AssetImage('asset/Female_Icon (2).png'),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/events');
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/events');
              },
              child: Text('Create an Event'),
          )
        ],
      ),
    );
  }
}