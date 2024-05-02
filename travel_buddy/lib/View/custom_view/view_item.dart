import 'package:flutter/material.dart';
import 'package:travel_buddy/View/location_detail.dart';
import 'package:travel_buddy/ViewModel/fetch_image.dart';

class CategoryItem extends StatefulWidget {
  final List<dynamic> categoryList;

  const CategoryItem({Key? key, required this.categoryList}) : super(key: key);

  @override
  _CategoryItemState createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.categoryList.length,
      itemBuilder: (context, index) {
        var place = widget.categoryList[index];
        return FutureBuilder(
          future: fetchImageUrl(place['displayName']['text']),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return buildCard(snapshot.data!, place);
            } else if (snapshot.hasError) {
              return buildCard("assets/destination.png", place);
            }
            return CircularProgressIndicator();
          },
        );
      },
    );
  }

  Widget buildCard(String imageUrl, dynamic place) {
    return  InkWell(
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => LocationDetailPage(place: place)),
      );
    },
    child:Card(
      child: Column(
        children: [
          Image.network(
            imageUrl,
            width: 160,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset("assets/destination.png", width: 160, height: 120, fit: BoxFit.cover);
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              place['displayName']['text'] ?? 'No name available',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            place['rating'].toString() + ' ★',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    )
    );
  }
}
