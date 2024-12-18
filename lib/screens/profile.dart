import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'my_event_list.dart';
import 'my_gift_list.dart';
import 'pledged_gifts.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  String userName = "";
  int numberOfFriends = 0;
  List<Map<String, dynamic>> events = [];
  String profileImageUrl = "";

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchEvents();
    _fetchFriendsCount();
  }

  Future<void> _fetchUserProfile() async {
    if (currentUserUid.isEmpty) return;
    try {
      DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(currentUserUid).get();
      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        setState(() {
          userName = userData['name'] ?? 'Unknown User';
          profileImageUrl = userData['imageUrl'] ?? ''; // Ensure this is fetched correctly
        });
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }


  Future<void> _fetchEvents() async {
    if (currentUserUid.isEmpty) return;
    try {
      QuerySnapshot eventSnapshot = await _firestore
          .collection('events')
          .where('userId', isEqualTo: currentUserUid)
          .get();

      setState(() {
        events = eventSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final date = (data['date'] as Timestamp).toDate();
          final eventId = doc.id;
          final eventName = data['name'] ?? 'Unnamed Event';
          final eventCategory = data['category'] ?? 'Uncategorized';

          return {
            'id': eventId,
            'name': eventName,
            'category': eventCategory,
            'date': date,
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching events: $e");
    }
  }


  Future<void> _fetchFriendsCount() async {
    if (currentUserUid.isEmpty) return;
    try {
      QuerySnapshot friendsSnapshot = await _firestore
          .collection('users')
          .doc(currentUserUid)
          .collection('friends')
          .get();

      setState(() {
        numberOfFriends = friendsSnapshot.size;
      });
    } catch (e) {
      print("Error fetching friends count: $e");
    }
  }

  Future<void> _saveEvent(String eventName, String category, DateTime date) async {
    if (currentUserUid.isEmpty || eventName.isEmpty || category.isEmpty) return;
    try {
      await _firestore.collection('events').add({
        'userId': currentUserUid,
        'name': eventName,
        'category': category,
        'date': Timestamp.fromDate(date),
        'timestamp': FieldValue.serverTimestamp(),
      });
      _fetchEvents();
    } catch (e) {
      print("Error saving event: $e");
    }
  }

  Future<void> _saveProfile(String name, int age, String gender) async {
    if (currentUserUid.isEmpty) return;
    try {
      // Assign profile image based on gender
      String genderImage = "assets/default-profile.png";
      if (gender.toLowerCase() == 'male') {
        genderImage = "asset/images/Male_Icon.png";
      } else if (gender.toLowerCase() == 'female') {
        genderImage = "asset/images/Female_Icon (2).png";
      }

      await _firestore.collection('users').doc(currentUserUid).update({
        'name': name,
        'age': age,
        'gender': gender,
        'profileImageUrl': genderImage,
      });

      setState(() {
        profileImageUrl = genderImage; // Update local profile image
      });

      _fetchUserProfile();
    } catch (e) {
      print("Error saving profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('users').doc(currentUserUid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data!.data() == null) {
                return Text('No user data found');
              }
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              String imageUrl = userData['imageUrl'] ?? '';
              return CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage("asset/images/person icon.jpg"),
              );

            },
        ),
          SizedBox(height: 20),
            Text(
              userName.isNotEmpty ? userName : "Loading...",
              style: TextStyle(
                fontFamily: "Parkinsans",
                fontSize: 30,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '$numberOfFriends Friends',
              style: TextStyle(
                fontFamily: "Parkinsans",
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showNewEventDialog(context),
                  icon: Icon(Icons.event, color: Colors.deepPurple),
                  label: Text('New Event'),
                ),
                SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () => _showEditProfileDialog(context),
                  icon: Icon(Icons.edit, color: Colors.deepPurple),
                  label: Text('Edit Profile'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final String eventId = event['id'];
                  final String eventName = event['name'];
                  final String category = event['category'];
                  final DateTime date = event['date'];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        "$eventName ($category) - ${date.toLocal()}",
                        style: TextStyle(
                          fontFamily: "Parkinsans",
                          fontSize: 18,
                        ),
                      ),
                      leading: Icon(Icons.event_note, color: Colors.blueAccent),
                      onTap: () {
                        // Navigate to the Event Gift List page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GiftListPage(eventId: eventId ,eventName: eventName),
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
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to the Pledged Gifts page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyPledgedGiftsPage(),
                  ),
                );
              },
              icon: Icon(Icons.card_giftcard, color: Colors.deepPurple),
              label: Text(
                'View Pledged Gifts',
                style: TextStyle(
                  fontFamily: "Parkinsans",
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
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

  void _showNewEventDialog(BuildContext context) {
    TextEditingController eventNameController = TextEditingController();
    TextEditingController categoryController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create New Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: eventNameController,
                decoration: InputDecoration(labelText: 'Event Name'),
              ),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(labelText: 'Category'),
              ),
              ListTile(
                title: Text("Date: ${selectedDate.toLocal()}".split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(Duration(days: 365)),
                    lastDate: DateTime.now().add(Duration(days: 365 * 10)),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (eventNameController.text.isNotEmpty &&
                    categoryController.text.isNotEmpty) {
                  _saveEvent(eventNameController.text, categoryController.text, selectedDate);
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


  void _showEditProfileDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController ageController = TextEditingController();
    TextEditingController genderController = TextEditingController();


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
              TextField(controller: ageController, decoration: InputDecoration(labelText: 'Age')),
              TextField(controller: genderController, decoration: InputDecoration(labelText: 'Gender')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveProfile(
                  nameController.text,
                  int.tryParse(ageController.text) ?? 0,
                  genderController.text,
                );
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
