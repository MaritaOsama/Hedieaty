import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'my_event_list.dart';
import 'profile.dart';
import 'home_page.dart';

class FGiftDetailsPage extends StatefulWidget {
  final String giftId;
  final String eventId;

  FGiftDetailsPage({required this.giftId, required this.eventId});

  @override
  _FGiftDetailsPageState createState() => _FGiftDetailsPageState();
}

class _FGiftDetailsPageState extends State<FGiftDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool _isPledged = false;
  File? _selectedImage;

  Future<Map<String, dynamic>?> fetchGiftDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('gifts')
          .doc(widget.giftId)
          .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print("Error fetching gift details: $e");
      return null;
    }
  }

  Future<void> updateGiftDetails() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('gifts')
          .doc(widget.giftId)
          .update({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'category': _categoryController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'isPledged': _isPledged,
        // Add logic to upload and save the image if necessary
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gift details updated successfully!')),
      );
    } catch (e) {
      print("Error updating gift details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update gift details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gift Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder(
        future: fetchGiftDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading gift details'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Gift not found'));
          }

          final gift = snapshot.data as Map<String, dynamic>;

          // Initialize fields if not already populated
          _nameController.text = gift['name'] ?? '';
          _descriptionController.text = gift['description'] ?? '';
          _categoryController.text = gift['category'] ?? '';
          _priceController.text = gift['price']?.toString() ?? '';
          _isPledged = gift['isPledged'] ?? false;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Gift Name'),
                    enabled: !_isPledged,
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a name' : null,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                    enabled: !_isPledged,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _categoryController,
                    decoration: InputDecoration(labelText: 'Category'),
                    enabled: !_isPledged,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(labelText: 'Price'),
                    enabled: !_isPledged,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status: ${_isPledged ? "Pledged" : "Available"}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Switch(
                        value: _isPledged,
                        onChanged: !_isPledged
                            ? (value) {
                          setState(() {
                            _isPledged = value;
                          });
                        }
                            : null, // Disable switch if pledged
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: !_isPledged ? updateGiftDetails : null,
                      child: Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
              break;
          }
        },
        currentIndex: 2,
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
