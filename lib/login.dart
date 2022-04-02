import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatelessWidget {
  final GoogleSignIn googleSignIn;
  final GoogleSignInAccount? currentUser;
  final Function updateCurrentUser;

  const Login({
    Key? key,
    required this.googleSignIn,
    required this.currentUser,
    required this.updateCurrentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zesty',
            style: TextStyle(fontFamily: 'Cookie', fontSize: 35, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.amber[900],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Zesty, Please Sign In',
              style: TextStyle(fontSize: 30),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: signIn,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Sign in', style: TextStyle(fontSize: 30)),
                )
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signIn() async {
    try {
      GoogleSignInAccount? newUser = await googleSignIn.signIn();
      GoogleSignInAuthentication? userAuth = await newUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: userAuth?.accessToken,
        idToken: userAuth?.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      FirebaseFirestore.instance
          .collection('users')
          .doc(newUser!.email)
          .get()
          .then((user) {
        if (!user.exists) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(newUser.email)
              .set({
            'displayName': newUser.displayName,
            'ingredients': [],
            'savedRecipes': [],
          });
        }
      });
      updateCurrentUser(newUser);
    } catch (e) {
      print('Error signing in $e');
    }
  }
}
