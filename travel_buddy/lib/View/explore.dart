import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';

class ExplorePage extends StatefulWidget {
  final String userId;
  ExplorePage({Key? key, required this.userId}) : super(key: key);

  @override
  ExplorePageScreen createState() => ExplorePageScreen();
}

class ExplorePageScreen extends State<ExplorePage> {
  late LocationData _currentLocation;
  var _places = [];

  @override
  void initState() {
    super.initState();
    print("InitState called");
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
  _fetchPlaces();
} catch (e) {
  print('Exception during getting location: ${e.toString()}');
}

  }


  void _fetchPlaces() async {
    String url = 'https://places.googleapis.com/v1/places:searchNearby?key=AIzaSyA4bO5sTk2V0EpxkcjuXJMKfqEE_fWuxVU';
    var headers = {
      'Content-Type': 'application/json',
      'X-Goog-FieldMask': '*'
    };
    var body = json.encode({
      "includedTypes": ["restaurant"],
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
        _places = json.decode(response.body)['places'];
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
    body: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, 
        crossAxisSpacing: 10, 
        mainAxisSpacing: 10, 
        childAspectRatio: 1 / 1, 
      ),
      itemCount: _places.length,
      itemBuilder: (context, index) {
        var place = _places[index];
        String name = place['displayName']['text'];
        String rating = place['rating'].toString();

        return Card(
          elevation: 2,
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 2),  
                Text(rating),
              ],
            ),
          ),
        );
      },
    ),
  );
}


}
