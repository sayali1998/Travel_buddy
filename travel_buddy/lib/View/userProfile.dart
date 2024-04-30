import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ensure you have this import

class UserProfileScreen extends StatefulWidget {
  final String userId;

  UserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  UserProfile createState() => UserProfile();
}

class UserProfile extends State<UserProfileScreen> {
  Map<String, dynamic>? userDetails;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  void _fetchUserDetails() async {
    try {
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      if (userData.exists) {
        setState(() {
          userDetails = userData.data() as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      print('Failed to fetch user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('User Profile'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('User Profile'),
        ),
        body: ListView(
          children: <Widget>[
            userDetails!['profileImageUrl'] != null
                ? Image.network(userDetails!['profileImageUrl'], height: 250, fit: BoxFit.cover)
                : Placeholder(fallbackHeight: 200), // Placeholder in case image is not available
            ListTile(
              title: Text('Username'),
              subtitle: Text(userDetails!['username'] ?? 'N/A'),
            ),
            ListTile(
              title: Text('Email'),
              subtitle: Text(userDetails!['email'] ?? 'N/A'),
            ),
            ListTile(
              title: Text('Age'),
              subtitle: Text('${userDetails!['age'] ?? 'N/A'}'),
            ),
            ListTile(
              title: Text('Gender'),
              subtitle: Text(userDetails!['gender'] ?? 'N/A'),
            ),
            ListTile(
              title: Text('Home Location'),
              subtitle: Text(userDetails!['homeLocation'] ?? 'N/A'),
            ),
          ],
        ),
      );
    }
  }
}
