// views/gift_list_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/models/gift_model.dart';
import '../controllers/gift_controller.dart';
import 'home_page.dart';
import 'my_event_list.dart';
import 'profile.dart';
import 'my_gift_details.dart';

class GiftListPage extends StatefulWidget {
  final String eventId;
  final String eventName;

  GiftListPage({required this.eventId, required this.eventName});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  late CollectionReference giftsCollection;
  List<Gift> gifts = [];
  String sortBy = "name";

  @override
  void initState() {
    super.initState();
    giftsCollection = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('gifts');
    _loadGifts();
  }

  void _loadGifts() async {
    gifts = await GiftController.loadGifts(giftsCollection);
    setState(() {});
  }

  void _addGift() {
    GiftController.addGift(giftsCollection, _loadGifts, context);
  }

  void _deleteGift(String giftId) {
    GiftController.deleteGift(giftId, giftsCollection, _loadGifts, context);
  }

  void _editGift(String giftId, String currentName, String currentCategory) {
    GiftController.editGift(giftId, currentName, currentCategory, giftsCollection, _loadGifts, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.eventName} Gift List"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: sortBy,
                  icon: Icon(Icons.sort),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _sortGifts(newValue);
                    }
                  },
                  items: [
                    DropdownMenuItem(value: "name", child: Text("Sort by Name")),
                    DropdownMenuItem(value: "category", child: Text("Sort by Category")),
                    DropdownMenuItem(value: "status", child: Text("Sort by Status")),
                  ],
                ),
                ElevatedButton(
                  onPressed: _addGift,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                  child: Text("Add Gift"),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                final gift = gifts[index];
                return GiftCard(
                  gift: gift,
                  onEdit: () => _editGift(gift.id, gift.name, gift.category),
                  onDelete: () => _deleteGift(gift.id),
                  onViewDetails: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GiftDetailsPage(giftId: gift.id, eventId: widget.eventId),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
              break;
            case 1:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EventListPage()));
              break;
            case 2:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage()));
              break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  void _sortGifts(String criteria) {
    setState(() {
      sortBy = criteria;
      if (criteria == 'name') {
        gifts.sort((a, b) => a.name.compareTo(b.name));
      } else if (criteria == 'category') {
        gifts.sort((a, b) => a.category.compareTo(b.category));
      } else if (criteria == 'status') {
        gifts.sort((a, b) => a.isPledged.toString().compareTo(b.isPledged.toString()));
      }
    });
  }
}

class GiftCard extends StatelessWidget {
  final Gift gift;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewDetails;

  GiftCard({
    required this.gift,
    required this.onEdit,
    required this.onDelete,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onViewDetails,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          title: Text(gift.name, style: TextStyle(color: gift.isPledged ? Colors.grey : Colors.black, fontWeight: FontWeight.bold)),
          subtitle: Text(gift.category),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(onPressed: onEdit, icon: Icon(Icons.edit, color: Colors.orange)),
              IconButton(onPressed: onDelete, icon: Icon(Icons.delete, color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
