import 'package:flutter/material.dart';
import 'home_page.dart';

class Gift {
  String name;
  String category;
  bool isPledged;

  Gift({required this.name, required this.category, this.isPledged = false});
}


class GiftListPage extends StatefulWidget {
  final String friendName;

  GiftListPage({required this.friendName});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  // Sample list of gifts
  List<Gift> gifts = [
    Gift(name: "Laptop", category: "Electronics"),
    Gift(name: "Book", category: "Books", isPledged: true),
    Gift(name: "Watch", category: "Accessories"),
  ];

  String sortBy = "name"; // Default sorting criteria

  // Function to sort the gift list
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

  // Function to add a new gift
  void _addGift() {
    setState(() {
      gifts.add(Gift(name: "New Gift", category: "Uncategorized"));
    });
  }

  // Function to delete a gift
  void _deleteGift(int index) {
    setState(() {
      gifts.removeAt(index);
    });
  }

  // Function to edit a gift
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
        title: Text("${widget.friendName}'s Gift List"),
        actions: [
          // Add gift button
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addGift,
            tooltip: "Add a new gift",
          ),
        ],
      ),
      body: Column(
        children: [
          // Sorting buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: ElevatedButton(
                  onPressed: () => _sortGifts('name'),
                  child: Text('Sort by Name'),
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: ElevatedButton(
                  onPressed: () => _sortGifts('category'),
                  child: Text('Sort by Category'),
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: ElevatedButton(
                  onPressed: () => _sortGifts('status'),
                  child: Text('Sort by Status'),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                final gift = gifts[index];
                return ListTile(
                  title: Text(
                    gift.name,
                    style: TextStyle(
                      color: gift.isPledged ? Colors.grey : Colors.black,
                    ),
                  ),
                  subtitle: Text(gift.category),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit button (disabled if pledged)
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: gift.isPledged
                            ? null
                            : () {
                          _editGift(index, "Edited Gift", "Edited Category");
                        },
                        color: gift.isPledged ? Colors.grey : Colors.blue,
                      ),
                      // Delete button
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
