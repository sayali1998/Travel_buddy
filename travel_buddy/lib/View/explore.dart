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
    _getLocation();
  }

  void _getLocation() async {
    var location = new Location();
    try {
      _currentLocation = await location.getLocation();
      print(_currentLocation);
      _fetchPlaces();
    } catch (e) {
      print('Could not get location: ${e.toString()}');
    }
  }

  void _fetchPlaces() async {
    String url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_currentLocation.latitude},${_currentLocation.longitude}&radius=1500&type=restaurant&key=AIzaSyA4bO5sTk2V0EpxkcjuXJMKfqEE_fWuxVU';
    var response = await http.get(Uri.parse(url));
    print(response);
    if (response.statusCode == 200) {
      setState(() {
        _places = json.decode(response.body)['results'];
      });
    } else {
      print('Failed to load places');
    }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Nearby Places'),
      ),
      body: ListView.builder(
        itemCount: _places.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_places[index]['name']),
            subtitle: Text(_places[index]['vicinity']),
          );
        },
      ),
    );
  }
}
