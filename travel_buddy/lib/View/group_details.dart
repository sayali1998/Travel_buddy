import 'package:flutter/material.dart';

class GroupDetails extends StatelessWidget {
 final String groupId;

 GroupDetails({Key? key, required this.groupId}) : super(key: key);

 @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Details'),
      ),
      body: Center(
        child: Text('Group ID: $groupId'),
      ),
    );
 }
}