import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'my_gift_list.dart';

class GiftDetailsPage extends StatefulWidget {
  final String eventId;
  final String giftId;

  const GiftDetailsPage({required this.eventId, required this.giftId, Key? key}) : super(key: key);

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isPledged = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

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
        _isPledged = data['isPledged'] ?? false;
        _nameController.text = data['name'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _categoryController.text = data['category'] ?? '';
        _priceController.text = data['price'].toString();
      });
    }
  }

  Future<void> _saveGiftDetails() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('gifts')
          .doc(widget.giftId)
          .update({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'category': _categoryController.text,
        'price': double.parse(_priceController.text),
        'isPledged': _isPledged,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gift details updated successfully!')),
      );

      // Navigate to Gift List Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GiftListPage(
            eventId: widget.eventId,
            eventName: "Event Name", // Pass the appropriate event name here
          ),
        ),
      );
    }
  }

  // Call the pledgeGift function to notify the event owner
  Future<void> _pledgeGiftNotification() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('User is not logged in');
      return;
    }

    final giftName = _nameController.text;
    await pledgeGift(userId, widget.eventId, giftName);
  }

  Future<void> pledgeGift(String userId, String eventId, String giftName) async {
    try {
      // Fetch the event document
      final eventDoc = await FirebaseFirestore.instance.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        print('Error: Event document does not exist');
        return;
      }
      final eventOwnerId = eventDoc.data()?['userId'];
      if (eventOwnerId == null) {
        print('Error: Event owner ID is missing');
        return;
      }

      // Fetch the user document
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        print('Error: User document does not exist');
        return;
      }
      final userName = userDoc.data()?['name'];
      if (userName == null) {
        print('Error: User name is missing');
        return;
      }

      // Log the data
      print('Event Owner ID: $eventOwnerId');
      print('User Name: $userName');

      // Notify the event owner about the gift pledge
      await FirebaseFirestore.instance
          .collection('users')
          .doc(eventOwnerId)
          .collection('notifications')
          .add({
        'title': 'Gift Pledged',
        'type': 'gift_pledged',
        'message': '$userName has pledged your gift: $giftName.',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      print('Notification successfully created for $eventOwnerId');
    } catch (e) {
      print('Error in pledgeGift: $e');
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Gift Details', style: TextStyle(fontFamily: "Parkinsans")),
        backgroundColor: Colors.blueAccent,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              style: TextStyle(fontFamily: "Parkinsans"),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(fontFamily: "Parkinsans"),
              ),
              validator: (value) => value!.isEmpty ? 'Name is required' : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              style: TextStyle(fontFamily: "Parkinsans"),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(fontFamily: "Parkinsans"),
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _categoryController,
              style: TextStyle(fontFamily: "Parkinsans"),
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(fontFamily: "Parkinsans"),
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              style: TextStyle(fontFamily: "Parkinsans"),
              decoration: InputDecoration(
                labelText: 'Price',
                labelStyle: TextStyle(fontFamily: "Parkinsans"),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Price is required' : null,
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Pledged', style: TextStyle(fontFamily: "Parkinsans")),
              activeColor: Colors.blueAccent,
              value: _isPledged,
              onChanged: (value) {
                setState(() {
                  _isPledged = value;
                  // Trigger the notification when the gift is pledged
                  if (_isPledged) {
                    _pledgeGiftNotification(); // Notify the event owner
                  }
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveGiftDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: Text('Save', style: TextStyle(fontFamily: "Parkinsans")),
            ),
          ],
        ),
      ),
    );
  }
}
