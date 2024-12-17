import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/screens/my_gift_list.dart';
import 'home_page.dart';
import 'profile.dart';
import 'my_event_list.dart';
import 'friend_gift_list.dart';
import 'my_gift_list.dart';

class Event {
  String id;
  String name;
  String category;
  DateTime date;
  String status;

  Event({
    required this.id,
    required this.name,
    required this.category,
    required this.date,
  }) : status = _determineStatus(date);

  static String _determineStatus(DateTime date) {
    final now = DateTime.now();
    if (date.isAfter(now)) {
      return "Upcoming";
    } else if (date.isBefore(now)) {
      return "Past";
    } else {
      return "Current";
    }
  }

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Event',
      category: data['category'] ?? 'Uncategorized',
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}

class FEventListPage extends StatefulWidget {
  final String friendId;
  final String friendName;

  FEventListPage({required this.friendId, required this.friendName});

  @override
  _FEventListPageState createState() => _FEventListPageState();
}

class _FEventListPageState extends State<FEventListPage> {
  List<Event> events = [];
  String sortBy = "name"; // Default sorting criteria
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: widget.friendId)
          .get();

      final fetchedEvents = querySnapshot.docs
          .map((doc) => Event.fromFirestore(doc))
          .toList();

      setState(() {
        events = fetchedEvents;
        _sortEvents(sortBy);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching events: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _sortEvents(String criteria) {
    setState(() {
      sortBy = criteria;
      if (criteria == 'name') {
        events.sort((a, b) => a.name.compareTo(b.name));
      } else if (criteria == 'category') {
        events.sort((a, b) => a.category.compareTo(b.category));
      } else if (criteria == 'status') {
        events.sort((a, b) => a.status.compareTo(b.status));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.friendName}'s Events List",
          style: TextStyle(
            fontFamily: "Parkinsans",
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius:
              BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Center(
              child: Text(
                "Explore ${widget.friendName}'s Events",
                style: TextStyle(
                  fontFamily: "Parkinsans",
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 16),

          // Dropdown for Sorting
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              value: sortBy,
              items: [
                DropdownMenuItem(
                  value: 'name',
                  child: Text('Sort by Name'),
                ),
                DropdownMenuItem(
                  value: 'category',
                  child: Text('Sort by Category'),
                ),
                DropdownMenuItem(
                  value: 'status',
                  child: Text('Sort by Status'),
                ),
              ],
              onChanged: (String? value) {
                if (value != null) {
                  _sortEvents(value);
                }
              },
              decoration: InputDecoration(
                labelText: "Sort Events",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),

          // Event List
          Expanded(
            child: events.isEmpty
                ? Center(
              child: Text(
                "No events found",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            )
                : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.event,
                        color: event.status == "Upcoming"
                            ? Colors.green
                            : event.status == "Past"
                            ? Colors.grey
                            : Colors.blue,
                        size: 40,
                      ),
                      title: Text(
                        event.name,
                        style: TextStyle(
                          fontFamily: "Parkinsans",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "${event.category} - ${event.status}",
                        style: TextStyle(
                          fontFamily: "Parkinsans",
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      trailing:
                      Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FGiftListPage(eventId: event.id, eventName: event.name),
                          ),
                        );
                      },
                    ),
                  ),
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
}
