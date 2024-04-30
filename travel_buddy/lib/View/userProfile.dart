import 'package:flutter/material.dart';
import 'package:travel_buddy/ViewModel/firebase_functions.dart';

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
      Map<String, dynamic>? userData = await fetchUserData(widget.userId);
      setState(() {
        userDetails = userData;
        print(userDetails);
      });
    } catch (e) {
      print('Failed to fetch user details: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Text("USer Profile");
  }
}