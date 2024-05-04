import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/widgets.dart';
import 'package:travel_buddy/ViewModel/fetch_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_controller.dart';

class LocationDetailPage extends StatefulWidget {
  final dynamic place;
  final String categoryType;

  const LocationDetailPage({Key? key, required this.place, required this.categoryType}) : super(key: key);

  @override
  _LocationDetailPageState createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends State<LocationDetailPage> {
  late Future<List<String>> futureImageUrls;
  CarouselController _controller = CarouselController();
  bool isFavorite = false;
  int _current =0;

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
    setState(() {
      isFavorite = favorites.contains(widget.place['id'].toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place['displayName']['text'] ?? 'Location Details', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildImageCarousel(),
            buildFeaturesSection(),

            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20),
              child: Row(
                children: [
                  Icon(Icons.location_pin),
                  Flexible( 
                      child: Text(
                        widget.place['formattedAddress'],
                        style: TextStyle(fontSize: 16),
                        maxLines: 44, 
                        overflow: TextOverflow.ellipsis, 
                      ),
                    ),
                ],
                )
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20),
              child: Row(
                children: [
                  Icon(Icons.phone),
                  Text(widget.place['nationalPhoneNumber'], style: TextStyle(fontSize: 16)),
                ],
                )
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                  children: [
                    Flexible( 
                      child: Text(
                        widget.place['editorialSummary']['text'],
                        style: TextStyle(fontSize: 16),
                        maxLines: 44, 
                        overflow: TextOverflow.ellipsis, 
                      ),
                    ),
                  ],
              ),
              ),
            buildReviewCarousel(),
            SizedBox(height: 30,)
          ],
        ),
      ),
    );
  }


  Widget buildImageCarousel() => FutureBuilder<List<String>>(
      future: futureImageUrls,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return Column(
            children: [
              CarouselSlider(
                carouselController: _controller,
                options: CarouselOptions(
                  height: 400,
                  enlargeCenterPage: true,
                  autoPlay: false,
                  viewportFraction: 1.0,
                  aspectRatio: 16/9,
                  initialPage: 0,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  },
                ),
                items: snapshot.data!
                    .map((url) => Container(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(0),
                            child: Image.network(url, fit: BoxFit.cover, width: MediaQuery.of(context).size.width),
                          ),
                        ))
                    .toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: snapshot.data!.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _controller.animateToPage(entry.key),
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black)
                              .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Failed to load images", style: TextStyle(color: Colors.red)),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      });



Widget buildFeaturesSection() => Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: formatFeatures().map((feature) => buildFeatureItem(feature['icon'], feature['text'])).toList(),
        ),
      ),
    );

  Widget buildFeatureItem(IconData icon, String text) {
  return Expanded(
    child: Container(
      alignment: Alignment.center,
      width: 100, 
      height: 80, 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.orange, size: 24),
          ),
          SizedBox(height: 4),
          Align(
            alignment: Alignment.center,
            child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ),
  );
}

  Widget buildReviewCarousel() => CarouselSlider(
        options: CarouselOptions(
          height: 100,
          enlargeCenterPage: true,
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 10),
          autoPlayAnimationDuration: Duration(milliseconds: 800),
          viewportFraction: 0.8,
        ),
        items: widget.place['reviews'].map<Widget>((review) {
          return Builder(
            builder: (BuildContext context) {
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    review['text']['text'],
                    style: TextStyle(fontSize: 14.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          );
        }).toList(),
      );

  String formatOpeningHours() {
    var hours = widget.place['regularOpeningHours']['weekdayDescriptions'];
    return hours.join('\n');
  }
List<Map<String, dynamic>> formatFeatures() {
  List<Map<String, dynamic>> features = [];

  features.add({
    'icon': Icons.event_seat,
    'text': widget.place.containsKey('outdoorSeating') && widget.place['outdoorSeating']
        ? 'Outdoor Seating'
        : 'Not Available',
  });

  features.add({
    'icon': Icons.pets,
    'text': widget.place.containsKey('allowsDogs') && widget.place['allowsDogs']
        ? 'Pets Allowed'
        : 'Pets Not Allowed',
  });

  features.add({
    'icon': Icons.music_note,
    'text': widget.place.containsKey('liveMusic') && widget.place['liveMusic']
        ? 'Live Music'
        : 'No music',
  });

  features.add({
    'icon': Icons.child_friendly,
    'text': widget.place.containsKey('menuForChildren') && widget.place['menuForChildren']
        ? 'Children Menu'
        : 'No Children Menu',
  });
  return features;
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
