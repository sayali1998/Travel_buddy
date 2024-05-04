import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart' as ws;
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  double lat;
  double long;

  MapScreen({Key? key, required this.lat, required this.long}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final ws.GoogleMapsDirections directionsApi = ws.GoogleMapsDirections(apiKey: 'AIzaSyA4bO5sTk2V0EpxkcjuXJMKfqEE_fWuxVU');
  Location location = Location();
  late LatLng _currentLocation= LatLng(43.038099, -76.130557);
  late LatLng _destination;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _destination = LatLng(widget.lat, widget.long);
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

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

    _locationData = await location.getLocation();
    setState(() {
      _currentLocation = LatLng(_locationData.latitude ?? 0.0, _locationData.longitude ?? 0.0);
      _setMarkers();
    });
    _showDirections();
  }

  void _setMarkers() {
    setState(() {
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId('current'),
        position: _currentLocation,
        infoWindow: InfoWindow(title: 'Current Location'),
      ));
      _markers.add(Marker(
        markerId: MarkerId('dest'),
        position: _destination,
        infoWindow: InfoWindow(title: 'Destination'),
      ));
    });
  }

   void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _setMarkers();
    _showDirections();
  }




  void _showDirections() async {
    var directions = await directionsApi.directionsWithLocation(
      ws.Location(lat: _currentLocation.latitude, lng: _currentLocation.longitude),
      ws.Location(lat: _destination.latitude, lng: _destination.longitude),
      travelMode: ws.TravelMode.driving,
    );
    if (directions.isOkay) {
      var route = directions.routes[0];
      var path = route.overviewPolyline.points;
      var points = _convertToLatLng(_decodePoly(path));
      _setPolyline(points);
      _zoomToFitRoute(points);
    } else {
      print('Error: ${directions.status}');
    }
  }

  List<LatLng> _convertToLatLng(List<PointLatLng> points) {
    return points.map((point) => LatLng(point.latitude, point.longitude)).toList();
  }

  List<PointLatLng> _decodePoly(String encoded) {
    List<PointLatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(PointLatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }


    void _setPolyline(List<LatLng> points) {
    setState(() {
      _polylines.clear();  // Clear existing polylines
      _polylines.add(Polyline(
        polylineId: PolylineId('route'),
        visible: true,
        points: points,
        width: 4,
        color: Colors.blue,
        startCap: Cap.roundCap,
        endCap: Cap.buttCap,
      ));
    });
  }

  void _zoomToFitRoute(List<LatLng> points) {
    if (points.isEmpty) return;
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    for (var point in points) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }
    mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0,  
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Map Directions'),
    ),
    body: GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _currentLocation,
        zoom: 12.0,
      ),
      markers: _markers,
      polylines: _polylines,
    ),
    floatingActionButton: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'but1',
          onPressed: _showDirections,
          tooltip: 'Get Directions',
          child: Icon(Icons.directions),
        ),
        SizedBox(height: 16),
        FloatingActionButton(
          heroTag: 'but2',
          onPressed: () => _zoomToFitRoute(_polylines.first.points),
          tooltip: 'Zoom To Fit Route',
          child: Icon(Icons.zoom_out_map),
        ),
      ],
    ),
  );
}

}

class PointLatLng {
  final double latitude;
  final double longitude;

  PointLatLng(this.latitude, this.longitude);
}
