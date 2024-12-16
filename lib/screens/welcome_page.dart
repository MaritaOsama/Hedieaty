import 'package:flutter/material.dart';
import 'package:hedieaty/screens/login2.dart';
import 'package:hedieaty/screens/login_page.dart';
import 'dart:async';
import 'home_page.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();

    // Navigate to home page after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Customize background color
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hedieaty',
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontFamily: "Parkinsans",
              ),
            ),
            SizedBox(height: 20),
            Icon(
              Icons.card_giftcard,
              size: 65,
              color: Colors.deepPurple,
            ),
          ],
        ),
      ),
    );
  }
}
