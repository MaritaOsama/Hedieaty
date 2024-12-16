import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'signup2.dart';  // Import your SignUpScreen here
import 'home_page.dart';  // Import your HomePage here

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login function
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Error: ${e.message}');
      return null;
    }
  }

  // Login handler
  Future<void> signIn() async {
    String email = emailController.text;
    String password = passwordController.text;

    // Call the login function
    User? user = await login(email, password);

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login successful!")));

      // Navigate to the Home Page after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),  // Replace with your HomePage widget
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error logging in!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Call the signIn method using the text controllers' values
                signIn();
              },
              child: Text("Login"),
            ),
            SizedBox(height: 10),
            // Redirect to the SignUp screen
            TextButton(
              onPressed: () {
                // Navigate to the SignUp screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              child: Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
