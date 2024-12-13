import 'package:flutter/material.dart';

class MyPledgedGiftsPage extends StatelessWidget {
  final List<String> pledgedGifts = [
    "Gift A",
    "Gift B",
    "Gift C",
    // Add more pledged gifts here...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pledged Gifts',
        style: TextStyle(
          fontFamily: "Parkinsans",
        ),),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Your Pledged Gifts',
              style: TextStyle(
                fontFamily: "Parkinsans",
                fontSize: 24,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: pledgedGifts.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.card_giftcard, color: Colors.blueAccent),
                      title: Text(
                        pledgedGifts[index],
                        style: TextStyle(
                          fontFamily: "Parkinsans",
                          fontSize: 18,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
