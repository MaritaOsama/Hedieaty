import 'package:flutter/material.dart';
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
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
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
