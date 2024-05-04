import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';
import 'package:travel_buddy/View/custom_view/view_item.dart';
import 'package:travel_buddy/View/gems.dart';
import 'package:travel_buddy/ViewModel/fetch_coordinates.dart';

class ExplorePage extends StatefulWidget {
  final String userId;
  ExplorePage({Key? key, required this.userId}) : super(key: key);

  @override
  ExplorePageScreen createState() => ExplorePageScreen();
}

class ExplorePageScreen extends State<ExplorePage> {
  late LocationData _currentLocation;
  List<dynamic> _category = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategoryType = 'restaurant';
  String _currentCity = 'Syracuse';  // Default city

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  void _getLocation() async {
    var location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    try {
      _currentLocation = LocationData.fromMap({
        "latitude": 37.7749, 
        "longitude": -122.4194
      });
      _fetchCategories("restaurant");
    } catch (e) {
      print('Exception during getting location: ${e.toString()}');
    }
  }

  void _fetchCategories(String type) async {
    if (_currentLocation == null) {
      print("Location not set");
      return;
    }

    String url = 'https://places.googleapis.com/v1/places:searchNearby?key=AIzaSyA4bO5sTk2V0EpxkcjuXJMKfqEE_fWuxVU';
    var headers = {
      'Content-Type': 'application/json',
      'X-Goog-FieldMask': '*'
    };
    var body = json.encode({
      "includedTypes": [type],
      "maxResultCount": 15,
      "locationRestriction": {
        "circle": {
          "center": {
            "latitude": _currentLocation.latitude,
            "longitude": _currentLocation.longitude,
          },
          "radius": 500.0
        }
      }
    });

    var response = await http.post(Uri.parse(url), headers: headers, body: body);
    if (response.statusCode == 200) {
      setState(() {
        _category = json.decode(response.body)['places'];
      });
    } else {
      print('Failed to load places: ${response.body}');
    }
  }

  void handleSearch(String query) async {
    var locationData = await getCoordinatesFromAddress(query);
    if (locationData != null) {
      setState(() {
        _currentLocation = locationData;
        _currentCity = query;  
        _fetchCategories(_selectedCategoryType);
      });
    } else {
      print("No valid location found for the query: $query");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Nearby Places'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(30.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search, color: Colors.white),  // Icon color
                      onPressed: () => handleSearch(_searchController.text),
                    ),
                    filled: true,
                    fillColor: Colors.grey[800],  // Dark fill color
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                  ),
                  onSubmitted: (value) {
                    handleSearch(value);
                  },
                  style: TextStyle(color: Colors.white),  // Text color
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Categories', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white), textAlign: TextAlign.left),
                ),
                SizedBox(height: 50, child: _buildCategoryList()),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Top Places', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white), textAlign: TextAlign.left),
                ),
                SizedBox(height: 215, child: CategoryItem(categoryList:_category, categoryType: _selectedCategoryType, userId: widget.userId,)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Hidden Gems', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white), textAlign: TextAlign.left),
                ),
                SizedBox(height: 200, child: FirestoreItemList(city: _currentCity)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    List<Map<String, dynamic>> categories = [
      {'name': 'Restaurants', 'icon': Icons.restaurant, 'type': 'restaurant'},
      {'name': 'Gym', 'icon': Icons.sports_gymnastics, 'type': 'gym'},
      {'name': 'Cafe', 'icon': Icons.coffee, 'type': 'cafe'},
      {'name': 'Park', 'icon': Icons.park_outlined, 'type': 'park'},
      {'name': 'Banks', 'icon': Icons.money, 'type': 'bank'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              setState(() {
                _selectedCategoryType = categories[index]['type'];
              });
              _fetchCategories(categories[index]['type']);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Chip(
                avatar: Icon(categories[index]['icon'], color: Colors.white),
                label: Text(categories[index]['name'], style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.deepPurple,  // Adjusted for dark theme
                padding: EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.deepPurple),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
