import 'package:flutter/material.dart';
import 'package:hedieaty/screens/my_event_list.dart';
import 'my_gift_list.dart';
import 'home_page.dart';


class GiftDetailsPage extends StatelessWidget {
  final Gift gift;

  GiftDetailsPage({required this.gift});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gift Details',
        style: TextStyle(
          fontFamily: "Parkinsans",
        ),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gift Name: ${gift.name}',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Parkinsans"),
            ),
            SizedBox(height: 10),
            Text(
              'Category: ${gift.category}',
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Parkinsans"),
            ),
            SizedBox(height: 10),
            Text(
              'Status: ${gift.isPledged ? "Pledged" : "Not Pledged"}',
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Parkinsans"),
            ),
          ],
        ),
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
