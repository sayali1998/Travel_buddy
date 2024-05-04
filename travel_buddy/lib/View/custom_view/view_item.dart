import 'package:flutter/material.dart';
import 'package:travel_buddy/View/location_detail.dart';
import 'package:travel_buddy/ViewModel/fetch_image.dart';
import 'package:travel_buddy/ViewModel/firebase_functions.dart';

class CategoryItem extends StatefulWidget {
  final List<dynamic> categoryList;
  final String categoryType;
  final String userId;
  const CategoryItem({Key? key, required this.categoryList, required this.categoryType, required this.userId}) : super(key: key);

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
  String userId = widget.userId;

  return InkWell(
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => LocationDetailPage(place: place, categoryType: widget.categoryType)),
      );
    },
    child: Card(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  place['displayName']['text'] ?? 'No name available',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchUserGroups(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return PopupMenuButton<String>(
                          onSelected: (String result) {
                          },                
                          itemBuilder: (BuildContext context) => snapshot.data!
                            .map((group) => PopupMenuItem<String>(
                              value: group['groupId'],
                              child: Text(group['groupName']),
                              onTap: () => {
                                addDestination(group['groupId'], place['displayName']['text'], imageUrl, place)
                              },
                            ))
                            .toList(),
                          icon: const Icon(Icons.more_vert),
                        );
                      } else {
                        return Text("No groups available");
                      }
                    } else if (snapshot.hasError) {
                      return Text("Error loading groups");
                    }
                    return CircularProgressIndicator();
                  },
                ),
              ],
            ),
          ),
          Text(
            place['rating'].toString() + ' ★',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}




}
