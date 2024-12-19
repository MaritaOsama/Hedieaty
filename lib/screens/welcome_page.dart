import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hedieaty/screens/login2.dart';
import 'package:hedieaty/screens/login_page.dart';
import 'home_page.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Define the bounce animation
    _animation = Tween<double>(begin: 0, end: -30).chain(
      CurveTween(curve: Curves.elasticOut),
    ).animate(_controller);

    // Start the animation
    _controller.forward();

    // Navigate to login screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Customize background color
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animation.value),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hedieaty',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                      fontFamily: "Parkinsans",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.card_giftcard,
                    size: 65,
                    color: Colors.deepPurple,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
