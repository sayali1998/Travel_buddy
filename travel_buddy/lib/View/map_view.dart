import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapViewPage extends StatefulWidget {
  final double destinationLat;
  final double destinationLng;

  MapViewPage({Key? key, required this.destinationLat, required this.destinationLng}) : super(key: key);

  @override
  _MapViewPageState createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  late GoogleMapController mapController;
  final Location _location = Location();
  Set<Marker> _markers = {};
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _location.onLocationChanged.listen((l) {
      if (l != null) {
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(l.latitude!, l.longitude!), zoom: 15),
          ),
        );
      }
    });
  setState(() {
    _markers.add(
      Marker(
        markerId: MarkerId("dest"),
        position: LatLng(widget.destinationLat, widget.destinationLng),
        infoWindow: InfoWindow(title: 'Hotel Location'),
      ),
    );
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map View"),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng((widget.destinationLat), (widget.destinationLng)),
          zoom: 14.0,
        ),
        markers: _markers,
      ),
    );
  }
}
