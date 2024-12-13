import 'package:flutter/material.dart';
import 'friend_gift_details_page.dart';
import 'home_page.dart';

class FGift {
  String name;
  String category;
  bool isPledged;

  FGift({required this.name, required this.category, this.isPledged = false});
}

class FGiftListPage extends StatefulWidget {
  final String friendName;

  FGiftListPage({required this.friendName});

  @override
  _FGiftListPageState createState() => _FGiftListPageState();
}

class _FGiftListPageState extends State<FGiftListPage> {
  List<FGift> gifts = [
    FGift(name: "Phone", category: "Electronics"),
    FGift(name: "Kindle", category: "Books", isPledged: true),
    FGift(name: "Bracelet", category: "Accessories"),
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
    setState(() {
      gifts.add(FGift(name: "New Gift", category: "Uncategorized"));
    });
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
        title: Text(
          "${widget.friendName}'s Gift List",
          style: TextStyle(fontFamily: "Parkinsans"),
        ),
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
                  elevation: 16,
                  style: TextStyle(color: Colors.blue, fontFamily: "Parkinsans"),
                  underline: Container(
                    height: 2,
                    color: Colors.blue,
                  ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    "Add Gift",
                    style: TextStyle(fontFamily: "Parkinsans"),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                final gift = gifts[index];
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
                    subtitle: Text(
                      gift.category,
                      style: TextStyle(fontFamily: "Parkinsans"),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: gift.isPledged
                              ? null
                              : () {
                            _editGift(index, "Edited Gift", "Edited Category");
                          },
                          color: gift.isPledged ? Colors.grey : Colors.blue,
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteGift(index);
                          },
                          color: Colors.red,
                        ),
                      ],
                    ),
                    tileColor: gift.isPledged ? Colors.lightGreen[100] : Colors.white,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FGiftDetailsPage(gift: gift),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
