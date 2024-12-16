import 'package:flutter/material.dart';
import 'package:hedieaty/screens/profile.dart';
import 'my_gift_details.dart';
import 'home_page.dart';
import 'my_event_list.dart';

class Gift {
  String name;
  String category;
  bool isPledged;

  Gift({required this.name, required this.category, this.isPledged = false});
}

class GiftListPage extends StatefulWidget {
  // final String friendName;
  //
  // GiftListPage({required this.friendName});

  final String event;
  GiftListPage({required this.event});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  List<Gift> gifts = [
    Gift(name: "Laptop", category: "Electronics"),
    Gift(name: "Book", category: "Books", isPledged: true),
    Gift(name: "Watch", category: "Accessories"),
  ];

  String sortBy = "name";

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
              onPressed: () {
                if (newName.isNotEmpty && newCategory.isNotEmpty) {
                  setState(() {
                    gifts.add(Gift(name: newName, category: newCategory));
                  });
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

  void _deleteGift(int index) {
    setState(() {
      gifts.removeAt(index);
    });
  }

  void _editGift(int index, String newName, String newCategory) {
    setState(() {
      gifts[index].name = newName;
      gifts[index].category = newCategory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.event}'s Gift List", style: TextStyle(fontFamily: "Parkinsans")),
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
                  child: Text("Add Gift", style: TextStyle(fontFamily: "Parkinsans")),
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
                      _editGift(index, "Edited Gift", "Edited Category");
                    }
                  },
                  onDelete: () {
                    _deleteGift(index);
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GiftDetailsPage(gift: gift)),
                    );
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
        currentIndex: 0, // Set the active tab index
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
}

class GiftCard extends StatelessWidget {
  final Gift gift;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  GiftCard({required this.gift, required this.onEdit, required this.onDelete, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          gift.name,
          style: TextStyle(
            color: gift.isPledged ? Colors.grey : Colors.black,
            fontFamily: "Parkinsans",
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(gift.category, style: TextStyle(fontFamily: "Parkinsans")),
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
        onTap: onTap,
      ),
    );
  }
}