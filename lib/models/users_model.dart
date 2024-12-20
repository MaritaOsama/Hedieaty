import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signup(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
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
    User? user = _auth.currentUser;
    if (user != null) {
      String uid = user.uid;
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'password': password,
      });
    }
  }
}
