import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyPledgedGiftsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<List<Map<String, dynamic>>> _fetchPledgedGifts() async {
    List<Map<String, dynamic>> pledgedGifts = [];
    if (currentUserUid.isEmpty) return pledgedGifts;

    try {
      // Get events for the current user
      QuerySnapshot eventsSnapshot = await _firestore
          .collection('events')
          .where('userId', isEqualTo: currentUserUid)
          .get();

      // Iterate through events and fetch pledged gifts
      for (var eventDoc in eventsSnapshot.docs) {
        String eventId = eventDoc.id;

        // Fetch only pledged gifts for the current event
        QuerySnapshot giftsSnapshot = await _firestore
            .collection('events')
            .doc(eventId)
            .collection('gifts')
            .where('isPledged', isEqualTo: true) // Filter for pledged gifts
            .get();

        for (var giftDoc in giftsSnapshot.docs) {
          final giftData = giftDoc.data() as Map<String, dynamic>;
          pledgedGifts.add({
            'eventName': eventDoc['name'] ?? 'Unknown Event',
            'giftName': giftData['name'] ?? 'Unnamed Gift',
            'pledger': giftData['pledger'] ?? 'Anonymous',
          });
        }
      }
    } catch (e) {
      print("Error fetching pledged gifts: $e");
    }
    return pledgedGifts;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pledged Gifts',
          style: TextStyle(
            fontFamily: "Parkinsans",
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPledgedGifts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No pledged gifts found.'));
          }

          final pledgedGifts = snapshot.data!;
          return ListView.builder(
            itemCount: pledgedGifts.length,
            itemBuilder: (context, index) {
              final gift = pledgedGifts[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.card_giftcard, color: Colors.deepPurple),
                  title: Text(
                    gift['giftName'] ?? 'Unnamed Gift',
                    style: TextStyle(
                      fontFamily: "Parkinsans",
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    'Event: ${gift['eventName']}\nPledger: ${gift['pledger']}',
                    style: TextStyle(
                      fontFamily: "Parkinsans",
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
