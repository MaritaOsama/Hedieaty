import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'my_event_list.dart';
import 'my_gift_details.dart';
import 'profile.dart';

class Gift {
  String id;
  String name;
  String category;
  bool isPledged;

  Gift({required this.id, required this.name, required this.category, this.isPledged = false});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'isPledged': isPledged,
    };
  }

  factory Gift.fromMap(String id, Map<String, dynamic> map) {
    return Gift(
      id: id,
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
    giftsCollection = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('gifts');
    _loadGifts();
  }

  // Load gifts from Firestore
  void _loadGifts() async {
    try {
      QuerySnapshot querySnapshot = await giftsCollection.get();
      setState(() {
        gifts = querySnapshot.docs
            .map((doc) => Gift.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      print("Error loading gifts: $e");
    }
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
                  Gift newGift = Gift(id: '', name: newName, category: newCategory);
                  try {
                    await giftsCollection.add(newGift.toMap());
                    _loadGifts();
                    Navigator.pop(context);
                  } catch (e) {
                    print("Error adding gift: $e");
                  }
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this gift?"),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await giftsCollection.doc(giftId).delete();
                  _loadGifts(); // Reload gifts after deletion
                  Navigator.pop(context);
                } catch (e) {
                  print("Error deleting gift: $e");
                }
              },
              child: Text("Delete"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the confirmation dialog
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _editGift(String giftId, String currentName, String currentCategory) async {
    TextEditingController nameController = TextEditingController(text: currentName);
    TextEditingController categoryController = TextEditingController(text: currentCategory);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Gift"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Gift Name"),
              ),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(labelText: "Gift Category"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String newName = nameController.text;
                String newCategory = categoryController.text;

                if (newName.isNotEmpty && newCategory.isNotEmpty) {
                  try {
                    await giftsCollection.doc(giftId).update({
                      'name': newName,
                      'category': newCategory,
                    });
                    _loadGifts();
                    Navigator.pop(context);
                  } catch (e) {
                    print("Error editing gift: $e");
                  }
                }
              },
              child: Text("Save Changes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without saving
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
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
                  onEdit: () {
                    if (!gift.isPledged) {
                      _editGift(gift.id, gift.name, gift.category); // Use gift.id for editing
                    }
                  },
                  onDelete: () {
                    _deleteGift(gift.id); // Use gift.id for deleting
                  },
                  onViewDetails: () {
                    // Navigate to GiftDetailsPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GiftDetailsPage(
                          giftId: gift.id, // Pass gift ID
                          eventId: widget.eventId, // Pass event ID
                        ),
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
  final VoidCallback onViewDetails; // New callback for viewing details

  GiftCard({
    required this.gift,
    required this.onEdit,
    required this.onDelete,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onViewDetails, // Navigate to the details page when tapped
      child: Card(
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
      ),
    );
  }
}

