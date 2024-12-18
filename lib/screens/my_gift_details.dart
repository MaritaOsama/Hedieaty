import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Gift Details',
            style: TextStyle(fontFamily: "Parkinsans")),
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
                labelStyle: TextStyle(fontFamily: "Parkinsans")
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
              validator: (value) =>
              value!.isEmpty ? 'Price is required' : null,
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Pledged', style: TextStyle(fontFamily: "Parkinsans")),
              activeColor: Colors.blueAccent,
              value: _isPledged,
              onChanged: _isPledged
                  ? null
                  : (value) {
                setState(() => _isPledged = value);
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
