import 'package:flutter/material.dart';

class Event {
  String name;
  String category;
  DateTime date;
  String status; //"Upcoming", "Current", "Past"

  Event({required this.name, required this.category, required this.date})
      : status = _determineStatus(date);

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
  List<Event> events = [
    Event(name: "Birthday Party", category: "Celebration", date: DateTime.now().add(Duration(days: 7))),
    Event(name: "Conference", category: "Work", date: DateTime.now().add(Duration(days: -2))),
    Event(name: "Workshop", category: "Education", date: DateTime.now()),
  ];

  String sortBy = "name"; // Default sorting criteria

  // Function to sort the event list
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

  // Function to add a new event
  void _addEvent() {
    setState(() {
      events.add(Event(name: "New Event", category: "General", date: DateTime.now()));
    });
  }

  // Function to delete an event
  void _deleteEvent(int index) {
    setState(() {
      events.removeAt(index);
    });
  }

  // Function to edit an event
  void _editEvent(int index, String newName, String newCategory, DateTime newDate) {
    setState(() {
      events[index].name = newName;
      events[index].category = newCategory;
      events[index].date = newDate;
      events[index].status = Event._determineStatus(newDate); // Update status based on new date
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Events List"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addEvent,
            tooltip: "Add a new event",
          ),
        ],
      ),
      body: Column(
        children: [
          // Sorting buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: ElevatedButton(
                onPressed: () => _sortEvents('name'),
                child: Text('Sort by Name'),
              ),
              ),
              SizedBox(width: 10),
              Flexible(child: ElevatedButton(
                onPressed: () => _sortEvents('category'),
                child: Text('Sort by Category'),
              ),
              ),
              SizedBox(width: 10),
              Flexible(child: ElevatedButton(
                onPressed: () => _sortEvents('status'),
                child: Text('Sort by Status'),
              ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  title: Text(event.name),
                  subtitle: Text("${event.category} - ${event.status}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit button
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Implement edit functionality
                          _editEvent(index, "Edited Event", "Edited Category", DateTime.now());
                        },
                        color: Colors.blue,
                      ),
                      // Delete button
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteEvent(index);
                        },
                        color: Colors.red,
                      ),
                    ],
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
