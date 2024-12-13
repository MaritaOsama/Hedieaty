import 'package:flutter/material.dart';
import 'my_gift_list.dart';
import 'pledged_gifts.dart';
import 'home_page.dart';
import 'my_event_list.dart';

class ProfilePage extends StatelessWidget {
  final String userName = "John Doe";
  final int numberOfFriends = 120;
  final List<String> events = [
    "Music Concert",
    "Tech Meetup",
    "Art Exhibition",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage("https://www.example.com/profile-image.jpg"), // Replace with the actual image URL or asset
            ),
            SizedBox(height: 20),

            // User Name
            Text(
              userName,
              style: TextStyle(
                fontFamily: "Parkinsans",
                fontSize: 30,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 10),

            // Number of Friends
            Text(
              '$numberOfFriends Friends',
              style: TextStyle(
                fontFamily: "Parkinsans",
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 20),

            // Row of buttons (New Event, Edit Profile)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to create a new event screen
                  },
                  icon: Icon(Icons.event, color: Colors.deepPurple),
                  label: Text(
                    'New Event',
                    style: TextStyle(
                      fontFamily: "Parkinsans",
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    //primary: Colors.blueAccent,
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to edit profile screen
                  },
                  icon: Icon(Icons.edit, color: Colors.deepPurple),
                  label: Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontFamily: "Parkinsans",
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    //primary: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // List of User's Events
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        events[index],
                        style: TextStyle(
                          fontFamily: "Parkinsans",
                          fontSize: 18,
                        ),
                      ),
                      leading: Icon(Icons.event_note, color: Colors.blueAccent),
                      onTap: () {
                        // Navigate to the Event Gift List page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GiftListPage(friendName: ''),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Button to navigate to the Pledged Gifts page
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to the Pledged Gifts page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyPledgedGiftsPage(),
                  ),
                );
              },
              icon: Icon(Icons.card_giftcard, color: Colors.deepPurple),
              label: Text(
                'View Pledged Gifts',
                style: TextStyle(
                  fontFamily: "Parkinsans",
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                //primary: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
      // Navigation Bar
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
}
