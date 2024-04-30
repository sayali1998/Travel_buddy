import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange, // Changed to deep orange
        elevation: 0,
      ),
      body: userDetails == null
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          child: Column(
            children: [
              userDetails!['profileImageUrl'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(25), // Simplified radius
                      child: Image.network(
                        userDetails!['profileImageUrl'],
                        height: 250,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.orange[200], // Adjusted color
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(Icons.person, size: 120, color: Colors.orange[800]), // Adjusted color
                    ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    profileDetailTile('Username', userDetails!['username']),
                    profileDetailTile('Email', userDetails!['email']),
                    profileDetailTile('Age', '${userDetails!['age']}'),
                    profileDetailTile('Gender', userDetails!['gender']),
                    profileDetailTile('Home Location', userDetails!['homeLocation']),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget profileDetailTile(String title, String? value) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),  // Add margin to each tile
      decoration: BoxDecoration(
        color: Colors.yellow[100], // Bright yellow background for tiles
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w600)), // Enhanced color and weight
        subtitle: Text(value ?? 'N/A', style: TextStyle(fontSize: 16, color: Colors.black87)), // Enhanced readability
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
