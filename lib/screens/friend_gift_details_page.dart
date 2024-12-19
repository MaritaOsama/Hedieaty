import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


  class FGiftDetailsPage extends StatefulWidget {
    final String eventId;
    final String giftId;

    const FGiftDetailsPage({required this.eventId, required this.giftId, Key? key}) : super(key: key);

    @override
    _FGiftDetailsPageState createState() => _FGiftDetailsPageState();
  }

  class _FGiftDetailsPageState extends State<FGiftDetailsPage> {
    bool _isPledged = false;
    Map<String, dynamic>? _giftData;

    @override
    void initState() {
      super.initState();
      _loadGiftDetails();
    }

    Future<void> _loadGiftDetails() async {
      final giftDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('gifts')
          .doc(widget.giftId)
          .get();

      final data = giftDoc.data();
      if (data != null) {
        setState(() {
          _giftData = data;
          _isPledged = data['isPledged'] ?? false;
        });
      }
    }


    Future<void> _pledgeGift() async {
      if (!_isPledged) {
        // Get the current user's ID
        final currentUser = FirebaseAuth.instance.currentUser;
        final currentUserUid = currentUser?.uid;

        if (currentUserUid == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You need to be logged in to pledge a gift.')),
          );
          return;
        }

        // Fetch the current user's name from Firestore
        String? currentUserName;
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserUid)
              .get();

          currentUserName = userDoc.data()?['name'];

          if (currentUserName == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to fetch your name. Please try again.')),
            );
            return;
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch your name. Please try again.')),
          );
          return;
        }

        setState(() => _isPledged = true);

        try {
          await FirebaseFirestore.instance
              .collection('events')
              .doc(widget.eventId)
              .collection('gifts')
              .doc(widget.giftId)
              .update({
            'isPledged': true,
            'pledger': currentUserName, // Save the user's name
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You have pledged this gift!')),
          );
        } catch (e) {
          setState(() => _isPledged = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to pledge the gift. Please try again.')),
          );
        }
      }
    }



    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Friend\'s Gift Details',
            style: TextStyle(fontFamily: "Parkinsans"),
          ),
          backgroundColor: Colors.blueAccent,
        ),
        body: _giftData == null
            ? Center(child: CircularProgressIndicator())
            : Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent.shade100, Colors.blueAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Gift Details',
                        style: TextStyle(
                          fontFamily: "Parkinsans",
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(Icons.card_giftcard, color: Colors.blueAccent),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Name: ${_giftData!['name']}',
                            style: TextStyle(
                              fontFamily: "Parkinsans",
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.description, color: Colors.blueAccent),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Description: ${_giftData!['description']}',
                            style: TextStyle(
                              fontFamily: "Parkinsans",
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.category, color: Colors.blueAccent),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Category: ${_giftData!['category']}',
                            style: TextStyle(
                              fontFamily: "Parkinsans",
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.attach_money, color: Colors.blueAccent),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Price: ${_giftData!['price']}',
                            style: TextStyle(
                              fontFamily: "Parkinsans",
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isPledged ? null : _pledgeGift,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          _isPledged ? 'Pledged' : 'Pledge',
                          style: TextStyle(
                            fontFamily: "Parkinsans",
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
