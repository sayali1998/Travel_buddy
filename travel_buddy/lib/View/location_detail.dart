import 'package:flutter/material.dart';
import 'package:travel_buddy/ViewModel/fetch_image.dart';

class LocationDetailPage extends StatefulWidget {
  final dynamic place;

  const LocationDetailPage({Key? key, required this.place}) : super(key: key);

  @override
  _LocationDetailPageState createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends State<LocationDetailPage> {
  late Future<List<String>> futureImageUrls;

  @override
  void initState() {
    super.initState();
    futureImageUrls = fetchImageUrls(widget.place['displayName']['text'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place['displayName']['text'] ?? 'Location Details'),
      ),
      body: FutureBuilder<List<String>>(
        future: futureImageUrls,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text("Failed to load images"));
            }
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Image.network(snapshot.data![index], fit: BoxFit.cover);
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
