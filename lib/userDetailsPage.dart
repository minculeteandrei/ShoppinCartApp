import 'dart:async';
import 'package:flutter/material.dart';
import 'package:l5_iot/home.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserDetailsPage extends StatelessWidget {
  const UserDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User details"),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox.fromSize(
              size: Size(20, 30),
            ),
            Text("your email: " + FirebaseAuth.instance.currentUser!.email.toString(),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("your UserId: " + FirebaseAuth.instance.currentUser!.uid.toString(),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
                onPressed: () {Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyHomePage(title: "My ShoppingList App")));},
                child: Text("Continue"),
            )
          ],
        ),
      ),
    );
  }
}

