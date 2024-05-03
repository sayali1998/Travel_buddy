import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:travel_buddy/ViewModel/fetch_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationDetailPage extends StatefulWidget {
  final dynamic place;
  final String categoryType;

  const LocationDetailPage({Key? key, required this.place, required this.categoryType}) : super(key: key);

  @override
  _LocationDetailPageState createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends State<LocationDetailPage> {
  late Future<List<String>> futureImageUrls;
  bool isFavorite = false; // Track favorite state

  @override
  void initState() {
    super.initState();
    futureImageUrls = fetchImageUrls(widget.place['displayName']['text'] ?? '');
    loadFavoriteStatus();
  }

  void loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'favorites';
    List<String> favorites = prefs.getStringList(key) ?? [];
    final String currentPlaceId = widget.place['id'].toString();
    setState(() {
      isFavorite = favorites.contains(currentPlaceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place['displayName']['text'] ?? 'Location Details'),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            color: isFavorite ? Colors.red : Colors.white,
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<String>>(
              future: futureImageUrls,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  return CarouselSlider(
                    options: CarouselOptions(
                      height: 250,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      viewportFraction: 0.8,
                    ),
                    items: snapshot.data!
                        .map((url) => ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(url, fit: BoxFit.cover, width: 1000),
                            ))
                        .toList(),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Failed to load images", style: TextStyle(color: Colors.red)),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                formatOpeningHours(),
                style: TextStyle(fontSize: 16),
              ),
            ),
            if (widget.place['reviews'] != null)
              CarouselSlider(
                options: CarouselOptions(
                  height: 100,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  viewportFraction: 0.8,
                ),
                items: widget.place['reviews'].map<Widget>((review) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          review['text']['text'],
                          style: TextStyle(fontSize: 14.0),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  String formatOpeningHours() {
    var hours = widget.place['regularOpeningHours']['weekdayDescriptions'];
    return hours.join('\n');
  }

  void toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'favorites';
    List<String> favorites = prefs.getStringList(key) ?? [];
    final String currentPlaceId = widget.place['id'].toString();

    setState(() {
      isFavorite = !isFavorite;
      if (isFavorite) {
        if (!favorites.contains(currentPlaceId)) {
          favorites.add(currentPlaceId);
          prefs.setStringList(key, favorites);
        }
      } else {
        favorites.remove(currentPlaceId);
        prefs.setStringList(key, favorites);
      }
    });
  }
}
