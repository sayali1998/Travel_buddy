import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {

  final String userId;

  HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  HomeScreen createState() => HomeScreen();
}

class HomeScreen extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
     return Scaffold(
    );
  }
}