import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/models/users_model.dart'; // Import the User Model
import 'package:hedieaty/screens/home_page.dart';

class SignUpController {
  final UserModel _userModel = UserModel(); // Model instance
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final BuildContext context;

  SignUpController({
    required this.context,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
  });

  Future<void> signUp() async {
    String email = emailController.text;
    String password = passwordController.text;
    String name = nameController.text;

    User? user = await _userModel.signup(email, password);

    if (user != null) {
      await _userModel.saveUserdata(name, email, password);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User signed up successfully!")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error signing up!")));
    }
  }
}
