import 'dart:async';

import 'package:flutter/material.dart';
import 'package:l5_iot/UserModel.dart';
import 'package:l5_iot/product.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  User user = FirebaseAuth.instance.currentUser!;
  final TextEditingController changeEmail = TextEditingController();
  final TextEditingController changeName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Center(
          child: Column(
            children: [
              SizedBox.fromSize(
                size: Size(20, 30),
              ),
              Text("UID: " + user.uid,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("email: " + user.email.toString(),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                decoration: InputDecoration(
                    labelText: "change email",
                    hintText: "type new email"
                ),
                controller: changeEmail,
              ),
              SizedBox.fromSize(
                size: Size(20, 20),
              ),
              Text("name: " + user.displayName.toString(),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox.fromSize(
                size: Size(20, 20),
              ),
              TextField(
                decoration: InputDecoration(
                    labelText: "Change Name",
                    hintText: "type new name"
                ),
                controller: changeName,
              ),
              ElevatedButton(
                onPressed: changeDetails,
                child: Text("Submit"),
              )
            ],
          ),
        ),
      )
    );
  }

  Future<void> changeDetails() async {
    if (changeEmail.text.trim() != "") {
      await user.updateEmail(changeEmail.text);
      FirebaseAuth.instance.signOut();
      Navigator.popUntil(context, ModalRoute.withName("/"));
    }
    if (changeName.text.trim() != "") {
      await user.updateDisplayName(changeName.text);
      //print(user.displayName);
      setState(() {
        user.reload();
        user = FirebaseAuth.instance.currentUser!;
      });
    }

    changeEmail.clear();
    changeName.clear();
  }
}
