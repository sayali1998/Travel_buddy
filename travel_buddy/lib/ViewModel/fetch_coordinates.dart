import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';

Future<LocationData?> getCoordinatesFromAddress(String address) async {
  String url = ('http://127.0.0.1:5000/geocode?city=$address');

  try {
    var response = await http.get(Uri.parse(url));
    var json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      double lat = json['latitude'];
      double lng = json['longitude'];
      return LocationData.fromMap({"latitude": lat, "longitude": lng});
    } else {
      print("Failed to fetch location: ${json}");
      return null;
    }
  } catch (e) {
    print("Exception caught: $e");
    return null;
  }
}
