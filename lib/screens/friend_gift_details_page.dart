import 'package:flutter/material.dart';
import 'friend_gift_list.dart';

class FGiftDetailsPage extends StatelessWidget {
  final FGift gift;

  FGiftDetailsPage({required this.gift});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gift Details', style: TextStyle(fontFamily: "Parkinsans")),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gift Name: ${gift.name}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "Parkinsans"),
            ),
            SizedBox(height: 10),
            Text('Category: ${gift.category}', style: TextStyle(fontSize: 18, fontFamily: "Parkinsans")),
            SizedBox(height: 10),
            Text('Status: ${gift.isPledged ? "Pledged" : "Not Pledged"}', style: TextStyle(fontSize: 18, fontFamily: "Parkinsans")),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Toggle pledge status
                  gift.isPledged = !gift.isPledged;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: gift.isPledged ? Colors.blueAccent : Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(
                  gift.isPledged ? "Pledged" : "Pledge Now",
                  style: TextStyle(fontFamily: "Parkinsans", fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
