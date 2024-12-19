import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Replace this with your HomePage widget
import 'home_page.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up function
  Future<User?> signup(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Error: ${e.message}');
      return null;
    }
  }

  Future<void> saveUserdata(String name, String email, String password) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'password': password,
      });
    }
  }

  // Sign up handler
  Future<void> signUp() async {
    String email = emailController.text;
    String password = passwordController.text;
    String name = nameController.text;

    // Call the signup function
    User? user = await signup(email, password);

    if (user != null) {
      // Save user data to Firestore
      await saveUserdata(name, email, password);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User signed up successfully!")));

      // Redirect to HomePage after successful sign-up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()), // Replace HomePage() with your actual home page widget
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error signing up!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Sign Up title with icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add, size: 50, color: Colors.deepPurple),
                  SizedBox(width: 10),
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      fontFamily: "Parkinsans",
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 60),

              // Name field
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person, color: Colors.deepPurple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Email field
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: Colors.deepPurple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),

              // Password field
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: Colors.deepPurple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 30),

              // Sign Up button
              ElevatedButton(
                onPressed: () {
                  // Call the signUp method using the text controllers' values
                  signUp();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    fontFamily: "Parkinsans",
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
