import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/friend_event_list_page.dart';
import 'screens/friend_gift_details_page.dart';
import 'screens/friend_gift_list.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/welcome_page.dart';
import 'screens/home_page.dart';
import 'screens/my_gift_details.dart';
import 'screens/my_gift_list.dart';
import 'screens/my_event_list.dart';
import 'screens/pledged_gifts.dart';
import 'screens/profile.dart';
import 'screens/signup2.dart';
import 'screens/login2.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(HedieatyApp());
}

class HedieatyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    var gift;
    return MaterialApp(
      title: 'Hedieaty',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomePage(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => HomePage(),
        '/events': (context) => FEventListPage(friendName: ''),
        '/gifts': (context) => FGiftListPage(friendName: ''),
        '/giftsDetails': (context) => FGiftDetailsPage(gift: gift),
        '/profile': (context) => ProfilePage(),
        '/pledgedGifts': (context) => MyPledgedGiftsPage(),
        '/myGifts': (context) => GiftListPage(eventId: '',eventName: ''),
        '/myEvents': (context) => EventListPage(),
        '/myGiftDetails': (context) => GiftDetailsPage(gift: gift),
      },
    );
  }
}