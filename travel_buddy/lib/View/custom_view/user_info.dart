import 'package:flutter/material.dart';

class UserInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const UserInfoRow({Key? key, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(width: 10),
          Text(value, style: TextStyle(color: Colors.black54, fontSize: 16)),
        ],
      ),
    );
  }
}
