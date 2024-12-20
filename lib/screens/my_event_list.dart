import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/models/list_events_model.dart';
import 'package:hedieaty/controllers/list_events_controller.dart';
import 'my_gift_list.dart';
import 'home_page.dart';
import 'profile.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final EventController _eventController = EventController();
  List<Event> events = [];
  String sortBy = "name";

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() async {
    try {
      final fetchedEvents = await _eventController.fetchEvents();
      setState(() {
        events = fetchedEvents;
      });
    } catch (e) {
      print('Error fetching events: $e');
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

  void _showAddEventDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
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
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.deepPurple)),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    categoryController.text.isNotEmpty) {
                  Event newEvent = Event(
                    id: '',
                    name: nameController.text,
                    category: categoryController.text,
                    date: selectedDate,
                    userId: FirebaseAuth.instance.currentUser!.uid,
                  );
                  _eventController.saveEvent(newEvent);
                  _loadEvents();
                  Navigator.pop(context);
                }
              },
              child: Text('Save', style: TextStyle(color: Colors.deepPurple)),
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
        title: Text(
          "My Event List",
          style: TextStyle(
            fontFamily: "Parkinsans",
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              value: sortBy,
              items: [
                DropdownMenuItem(value: 'name', child: Text('Sort by Name')),
                DropdownMenuItem(value: 'category', child: Text('Sort by Category')),
                DropdownMenuItem(value: 'status', child: Text('Sort by Status')),
              ],
              onChanged: (value) {
                if (value != null) _sortEvents(value);
              },
              decoration: InputDecoration(
                labelText: "Sort Events",
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: events.isEmpty
                ? Center(child: Text("No events added yet"))
                : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  elevation: 5.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text(
                      event.name,
                      style: TextStyle(
                        fontFamily: 'YourFontFamily', // Replace with your font family
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${event.category} - ${event.status}",
                      style: TextStyle(fontSize: 14),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GiftListPage(
                            eventId: event.id,
                            eventName: event.name,
                          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      currentIndex: 1, // Current page index for EventListPage
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
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Events',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
