import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final List<dynamic> categoryList;

  const CategoryItem({Key? key, required this.categoryList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: categoryList.length,
      itemBuilder: (context, index) {
        var place = categoryList[index];
        return Card(
          child: Column(
            children: [
              Image.asset("assets/destination.png", width: 160, height: 120, fit: BoxFit.cover),
              Text(place['displayName']['text']),
              Text(place['rating'].toString(), style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }
}
