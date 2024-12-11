import 'package:flutter/material.dart';
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
  final String friendName;

  GiftListPage({required this.friendName});

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
    setState(() {
      gifts.add(Gift(name: "New Gift", category: "Uncategorized"));
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
        title: Text("${widget.friendName}'s Gift List",
        style: TextStyle(
          fontFamily: "Parkinsans",
        ),),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addGift,
            tooltip: "Add a new gift",
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: ElevatedButton(
                onPressed: () => _sortGifts('name'),
                child: Text('Sort by Name',
                style: TextStyle(
                  fontFamily: "Parkinsans",
                ),),
              ),
              ),
              SizedBox(width: 10),
              Flexible(child: ElevatedButton(
                onPressed: () => _sortGifts('category'),
                child: Text('Sort by Category',
                style: TextStyle(
                  fontFamily: "Parkinsans",
                ),),
              ),
              ),
              SizedBox(width: 10),
              Flexible(child: ElevatedButton(
                onPressed: () => _sortGifts('status'),
                child: Text('Sort by Status',
                style: TextStyle(
                  fontFamily: "Parkinsans",
                ),),
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
                      fontFamily: "Parkinsans",
                    ),
                  ),
                  subtitle: Text(gift.category),
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
                        builder: (context) => GiftDetailsPage(gift: gift),
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
                MaterialPageRoute(builder: (context) => GiftListPage(friendName: 'Friend Placeholder')),
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
            icon: Icon(Icons.card_giftcard),
            label: 'Gifts',
          ),
        ],
      ),
    );
  }
}
