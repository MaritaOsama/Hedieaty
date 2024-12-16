import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'my_event_list.dart';

class Gift {
  String name;
  String category;
  bool isPledged;

  Gift({required this.name, required this.category, this.isPledged = false});

  // Convert Gift to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'isPledged': isPledged,
    };
  }

  // Convert a Firestore document to a Gift object
  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      isPledged: map['isPledged'] ?? false,
    );
  }
}

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
    // Access the Firestore collection for gifts inside a specific event
    giftsCollection = FirebaseFirestore.instance
        .collection('events')        // 'events' collection
        .doc(widget.eventId)           // The event document (ID passed to the page)
        .collection('gifts');        // 'gifts' subcollection

    // Load the gifts for the event
    _loadGifts();
  }

  void _loadGifts() async {
    QuerySnapshot querySnapshot = await giftsCollection.get();
    setState(() {
      gifts = querySnapshot.docs
          .map((doc) => Gift.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  void _addGift() {
    showDialog(
      context: context,
      builder: (context) {
        String newName = '';
        String newCategory = '';
        return AlertDialog(
          title: Text("Add New Gift"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Gift Name"),
                onChanged: (value) {
                  newName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: "Gift Category"),
                onChanged: (value) {
                  newCategory = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (newName.isNotEmpty && newCategory.isNotEmpty) {
                  // Create a new gift object
                  Gift newGift = Gift(name: newName, category: newCategory);

                  // Add the gift to the Firestore subcollection
                  await giftsCollection.add(newGift.toMap());

                  // Reload the list of gifts
                  _loadGifts();

                  Navigator.pop(context);
                }
              },
              child: Text("Add Gift"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _deleteGift(String giftId) async {
    await giftsCollection.doc(giftId).delete();
    _loadGifts(); // Reload gifts after deletion
  }

  void _editGift(String giftId, String newName, String newCategory) async {
    await giftsCollection.doc(giftId).update({
      'name': newName,
      'category': newCategory,
    });
    _loadGifts(); // Reload gifts after editing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.eventName}'s Gift List"),
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
                  onEdit: () {
                    if (!gift.isPledged) {
                      _editGift(gift.name, "Edited Gift", "Edited Category");
                    }
                  },
                  onDelete: () {
                    _deleteGift(gift.name); // Pass gift ID here
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation
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
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
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

  GiftCard({required this.gift, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          gift.name,
          style: TextStyle(
            color: gift.isPledged ? Colors.grey : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(gift.category),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit, color: Colors.orange),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
