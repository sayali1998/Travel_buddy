import 'package:flutter/material.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<UserLogin> createState() => UserLoginPage();
}

class UserLoginPage extends State<UserLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/author.png'),
            ),
          ],
        ),
      ),
    );
  }
}
