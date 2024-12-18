import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'friend_gift_details_page.dart';
import 'home_page.dart';
import 'my_event_list.dart';
import 'my_gift_details.dart';
import 'profile.dart';

class FGift {
  String id;
  String name;
  String category;
  String pledger;
  bool isPledged;

  FGift({required this.id, required this.name, required this.category, required this.pledger, this.isPledged = false});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'pledger': pledger,
      'isPledged': isPledged,
    };
  }

  factory FGift.fromMap(String id, Map<String, dynamic> map) {
    return FGift(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      pledger: map['pledger'] ?? 'Anonymous',
      isPledged: map['isPledged'] ?? false,
    );
  }
}

class FGiftListPage extends StatefulWidget {
  final String eventId;
  final String eventName;

  FGiftListPage({required this.eventId, required this.eventName});

  @override
  _FGiftListPageState createState() => _FGiftListPageState();
}

class _FGiftListPageState extends State<FGiftListPage> {
  late CollectionReference giftsCollection;
  List<FGift> gifts = [];
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
            .map((doc) => FGift.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      print("Error loading gifts: $e");
    }
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
                  onViewDetails: () {
                    // Navigate to GiftDetailsPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FGiftDetailsPage(
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
  final FGift gift;
  final VoidCallback onViewDetails; // New callback for viewing details

  GiftCard({
    required this.gift,
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
            ],
          ),
        ),
      ),
    );
  }
}

