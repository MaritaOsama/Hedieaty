import 'package:cloud_firestore/cloud_firestore.dart';
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
      setState(() => _isPledged = true);
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('gifts')
          .doc(widget.giftId)
          .update({'isPledged': true});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have pledged this gift!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend\'s Gift Details', style: TextStyle(fontFamily: "Parkinsans")),
        backgroundColor: Colors.blueAccent,
      ),
      body: _giftData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${_giftData!['name']}', style: TextStyle(fontFamily: "Parkinsans", fontSize: 18)),
            SizedBox(height: 8),
            Text('Description: ${_giftData!['description']}', style: TextStyle(fontFamily: "Parkinsans")),
            SizedBox(height: 8),
            Text('Category: ${_giftData!['category']}', style: TextStyle(fontFamily: "Parkinsans")),
            SizedBox(height: 8),
            Text('Price: ${_giftData!['price']}', style: TextStyle(fontFamily: "Parkinsans")),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isPledged ? null : _pledgeGift,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: Text(_isPledged ? 'Pledged' : 'Pledge', style: TextStyle(fontFamily: "Parkinsans")),
            ),
          ],
        ),
      ),
    );
  }
}
