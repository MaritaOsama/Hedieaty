import 'package:flutter/material.dart';
import 'home_page.dart';
import 'gift_details.dart';
import 'gift_list.dart';
import 'event_list.dart';
import 'pledged_gifts.dart';
import 'profile.dart';

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
