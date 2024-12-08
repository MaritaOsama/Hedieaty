import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/gift_details.dart';
import 'screens/gift_list.dart';
import 'screens/event_list.dart';
import 'screens/pledged_gifts.dart';
import 'screens/profile.dart';

void main() {
  runApp(HedieatyApp());
}

class HedieatyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Hedieaty',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/events': (context) => EventListPage(),
        '/gifts': (context) => GiftListPage(friendName: '',),
        '/giftsDetails': (context) => GiftDetailsPage(),
        '/profile': (context) => ProfilePage(),
        '/pledgedGifts': (context) => PledgedGiftsPage(),
      },
    );
  }
}

//try to commit