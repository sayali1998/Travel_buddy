import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_buddy/View/custom_view/user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_buddy/View/hidden_gem_dialog.dart';
import 'package:travel_buddy/View/userLogin.dart';

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

  void _signOut() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => UserLogin(title: "Login")),
      (Route<dynamic> route) => false, 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFAFAFA),
        elevation: 0, 
        title: Text('Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.black54),
            onPressed: _signOut,
          ),
        ],
      ),
      backgroundColor: Colors.white, 
      body: userDetails == null
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Color(0xFFFAFAFA), 
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      
                    ),
                    SizedBox(height: 0),
                    userDetails!['profileImageUrl'] != null
                        ? CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(userDetails!['profileImageUrl']),
                          )
                        : CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.deepPurple[200],
                            child: Icon(Icons.person, size: 60, color: Colors.deepPurple),
                          ),
                    SizedBox(height: 10),
                    Text(userDetails!['username'] ?? 'N/A', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(userDetails!['email'] ?? 'N/A', style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserInfoRow(label: 'Age:',  value:'${userDetails!['age']}'),
                    UserInfoRow(label: 'Gender:', value: userDetails!['gender']),
                    UserInfoRow(label: 'Home Location:', value: userDetails!['homeLocation']),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return HiddenGem(); 
            },
          );
        },
        child: Icon(Icons.diamond),
      ),
    );
  }

  
}
