import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';
import 'package:travel_buddy/View/custom_view/view_item.dart';

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

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

 void _getLocation() async {
    var location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

// Check if location services are enabled
_serviceEnabled = await location.serviceEnabled();
print("Service enabled check: $_serviceEnabled");
if (!_serviceEnabled) {
  _serviceEnabled = await location.requestService();
  print("Requested service enablement: $_serviceEnabled");
  if (!_serviceEnabled) {
    print("Location services are disabled after request.");
    return;
  }
}

// Check and request permission
_permissionGranted = await location.hasPermission();
print("Initial permission status: $_permissionGranted");
if (_permissionGranted == PermissionStatus.denied) {
  _permissionGranted = await location.requestPermission();
  print("Requested permission status: $_permissionGranted");
  if (_permissionGranted != PermissionStatus.granted) {
    print("Location permission not granted.");
    return;
  }
}

try {
  //_currentLocation = await location.getLocation().timeout(Duration(seconds: 30));
  //print("Location obtained: Latitude: ${_currentLocation.latitude}, Longitude: ${_currentLocation.longitude}");
  
  //Need to change this so that it gets current coordinates
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
            "latitude": 37.7937,//_currentLocation.latitude,
            "longitude": -122.3965, //currentLocation.longitude
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
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Categories', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.left),
                ),
                SizedBox(height: 50, child: _buildCategoryList()),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Top Places', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.left),
                ),
                SizedBox(height: 200, child: CategoryItem(categoryList:_category)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Hidden Gems', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.left),
                ),
                SizedBox(height: 200, child: CategoryItem(categoryList:[])),
              ],
            )

          ],
        ),
      ),
    );
  }

Widget _buildCategoryList() {
  List<Map<String, dynamic>> categories = [
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
            _fetchCategories(categories[index]['type']);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Chip(
              avatar: Icon(categories[index]['icon'], color: Colors.white),
              label: Text(categories[index]['name'], style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.amber,
              padding: EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.amber),
              ),
            ),
          ),
        );
      },
    ),
  );
}



}

