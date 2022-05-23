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
    user.reload();
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Center(
        child: Column(
          children: [
            Text("UID: " + user.uid),
            Text("email: " + user.email.toString()),
            TextField(
              decoration: InputDecoration(
                labelText: "change email",
                hintText: "type new email"
              ),
              controller: changeEmail,
            ),
            Text("name: " + user.displayName.toString()),
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
    );
  }

  Future<void> changeDetails() async {
    if (changeEmail.text.trim() != "") {
      await user.updateEmail(changeEmail.text);
      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
      Navigator.pop(context);
    }
    if (changeName.text.trim() != "") {
      await user.updateDisplayName(changeName.text);
    }

    setState(() {});
  }
}
