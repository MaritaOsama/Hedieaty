import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/screens/profile.dart';
import 'home_page.dart';
import 'my_gift_list.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
User? currentUser = _auth.currentUser;
String? userId = currentUser?.uid;

class Event {
  String id;
  String name;
  String category;
  DateTime date;
  String status;
  String userId;

  Event({
    required this.id,
    required this.name,
    required this.category,
    required this.date,
    required this.userId,
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
}


class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Event> events = [];
  String sortBy = "name"; // Default sorting criteria

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }


  // Load events from Firestore
  void _loadEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: user.uid)
          .get();

      List<Event> fetchedEvents = snapshot.docs.map((doc) {
        return Event(
          id: doc.id,  // Save the Firestore document ID
          name: doc['name'],
          category: doc['category'],
          date: (doc['date'] as Timestamp).toDate(),
          userId: doc['userId'],
        );
      }).toList();

      setState(() {
        events = fetchedEvents;
      });
    } else {
      print('No user is logged in!');
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

  // Add event dialog
  void _showAddEventDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Event', style: TextStyle(fontFamily: "Parkinsans"),),
          content: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Event Name'),
              ),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(labelText: 'Category'),
              ),
              ListTile(
                title: Text("Date: ${selectedDate.toLocal()}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? newDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (newDate != null) {
                    setState(() {
                      selectedDate = newDate;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    categoryController.text.isNotEmpty) {
                  // Save event to Firebase
                  _saveEvent(nameController.text, categoryController.text, selectedDate);
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveEvent(String name, String category, DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Create the event object with the current user's UID
      Event event = Event(
        name: name,
        category: category,
        date: date,
        userId: user.uid,
        id: '', // Dynamically fetch the user UID
      );

      // Save the event to Firestore under the user's UID
      DocumentReference eventRef = await FirebaseFirestore.instance.collection('events').add({
        'name': event.name,
        'category': event.category,
        'date': event.date,
        'status': event.status,
        'userId': event.userId, // Save the UID to Firestore
      });

      // Notify friends about the new event
      _sendEventNotifications(user.uid, event.name);

      // Refresh the event list after adding an event
      _loadEvents();
    } else {
      // Handle the case where the user is not logged in
      print('No user is logged in!');
    }
  }

  Future<void> _sendEventNotifications(String userId, String eventName) async {
    // Get user document to fetch user's name
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final userName = userDoc.data()?['name'];

    if (userName != null) {
      // Get the friends of the user
      final friendsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('friends')
          .get();

      // Notify each friend about the event creation
      for (var friendDoc in friendsSnapshot.docs) {
        final friendId = friendDoc.id;

        // Add notification to friend's notifications collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .collection('notifications')
            .add({
          'title': 'New Event Created',
          'type': 'event_created',
          'message': '$userName has created a new event: $eventName.',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Event List", style: TextStyle(fontFamily: "Parkinsans"),),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Center(
                child: Text(
                  "Explore Events",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "Parkinsans"),
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
                  DropdownMenuItem(value: 'name', child: Text('Sort by Name', style: TextStyle(fontFamily: "Parkinsans"))),
                  DropdownMenuItem(value: 'category', child: Text('Sort by Category', style: TextStyle(fontFamily: "Parkinsans"))),
                  DropdownMenuItem(value: 'status', child: Text('Sort by Status', style: TextStyle(fontFamily: "Parkinsans"))),
                ],
                onChanged: (String? value) {
                  if (value != null) {
                    _sortEvents(value);
                  }
                },
                decoration: InputDecoration(
                  labelText: "Sort Events",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Event List
            Expanded(
              child: events.isEmpty
                  ? Center(child: Text("No events added yet"))
                  : ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("${event.category} - ${event.status}", style: TextStyle(fontFamily: "Parkinsans")),
                        trailing: Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: () async {
                          // Fetch the event details using the event ID
                          DocumentSnapshot doc = await FirebaseFirestore.instance
                              .collection('events')
                              .doc(event.id)  // Use the event ID to get the document
                              .get();

                          // Create an Event object with the data fetched from Firestore
                          Event eventDetails = Event(
                            id: doc.id,
                            name: doc['name'],
                            category: doc['category'],
                            date: (doc['date'] as Timestamp).toDate(),
                            userId: doc['userId'],
                          );

                          // Navigate to the GiftListPage with the event details
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GiftListPage(eventId: event.id, eventName: event.name),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
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
}