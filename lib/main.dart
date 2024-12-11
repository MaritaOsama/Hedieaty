import 'package:flutter/material.dart';
import 'package:hedieaty/screens/friend_event_list_page.dart';
import 'package:hedieaty/screens/friend_gift_list.dart';
import 'package:hedieaty/screens/welcome_page.dart';
import 'screens/home_page.dart';
import 'screens/my_gift_details.dart';
import 'screens/my_gift_list.dart';
import 'screens/my_event_list.dart';
import 'screens/pledged_gifts.dart';
import 'screens/profile.dart';

void main() {
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
        '/events': (context) => FEventListPage(friendName: ''),
        '/gifts': (context) => FGiftListPage(friendName: ''),
        '/giftsDetails': (context) => GiftDetailsPage(gift: gift),
        '/profile': (context) => ProfilePage(),
        '/pledgedGifts': (context) => PledgedGiftsPage(),
        '/myGifts': (context) => GiftListPage(friendName: ''),
        '/myEvents': (context) => EventListPage()
      },
    );
  }
}