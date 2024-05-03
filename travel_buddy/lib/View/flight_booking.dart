import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FlightBookingPage extends StatefulWidget {
  final String userId;

  FlightBookingPage({Key? key, required this.userId}) : super(key: key);

  @override
  _FlightBookingPageState createState() => _FlightBookingPageState();
}

class _FlightBookingPageState extends State<FlightBookingPage> {
  final TextEditingController _departureAirportController = TextEditingController();
  final TextEditingController _arrivalAirportController = TextEditingController();
  List<dynamic> flights = [];

 void fetchFlights(String departureId, String arrivalId, String outboundDate, String returnDate) async {
  var url = 'https://serpapi.com/search.json?engine=google_flights&departure_id=$departureId&arrival_id=$arrivalId&gl=us&hl=en&currency=USD&outbound_date=$outboundDate&return_date=$returnDate&api_key=d971976dbaeab7a1af02e0d34fce913e124d9655e044280b89e9ff73f2085a54';

  try {
    var response = await http.get(Uri.parse(url));
    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        flights = jsonDecode(response.body)['best_flights'];
        print(flights);
      });
    } else {
      print('Failed to load flights: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching flights: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flight Booking'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: _departureAirportController,
              decoration: InputDecoration(
                labelText: 'Departure Airport',
              ),
            ),
            TextFormField(
              controller: _arrivalAirportController,
              decoration: InputDecoration(
                labelText: 'Arrival Airport',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                fetchFlights(_departureAirportController.text, _arrivalAirportController.text, "2024-05-04", "2024-05-10");
              },
              child: Text('Search Flights'),
            ),
            ...flights.map((flight) => ListTile(
              title: Text(flight['airline']), 
              subtitle: Text('${flight['departure_airport']['name']} to ${flight['arrival_airport']['name']}'), // Adjust based on actual API response structure
            )).toList(),
          ],
        ),
      ),
    );
  }
}
