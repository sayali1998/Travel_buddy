import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:convert';
import 'package:confetti/confetti.dart';
import 'package:travel_buddy/ViewModel/firebase_functions.dart';


class HotelBookingPage extends StatefulWidget {

  final String userId;
  final String userGroupId;

  HotelBookingPage({Key? key, required this.userId, required this.userGroupId}) : super(key: key);

  @override
  _HotelBookingPageState createState() => _HotelBookingPageState();
}

class _HotelBookingPageState extends State<HotelBookingPage> with SingleTickerProviderStateMixin{
  final TextEditingController _locationController = TextEditingController();
  List<dynamic> hotels = [];
  late AnimationController _animationController;
  late ConfettiController _confettiController;


  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> fetchRegionId(String query) async {
  var headers = {
    'X-RapidAPI-Key': '668dbe1064msh33d44a5ea9170f9p17a92ejsn59b549cc619d',
    'X-RapidAPI-Host': 'hotels-com-provider.p.rapidapi.com'
  };

  var response = await http.get(
    Uri.parse('https://hotels-com-provider.p.rapidapi.com/v2/regions?query=$query&domain=AE&locale=en_GB'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    var regions = data['data'] as List<dynamic>;

    // Check if there are any regions returned and select the first CITY type if available
    String? regionId;
    for (var region in regions) {
      if (region['type'] == "CITY") {
        regionId = region['gaiaId'];
        break;
      }
    }

    if (regionId != null) {
      fetchHotels(regionId);
    } else {
      print('No valid city region found for your query');
    }
  } else {
    print('Failed to load region: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}

Future<void> fetchHotels(String regionId) async {
  var headers = {
    'X-RapidAPI-Key': '668dbe1064msh33d44a5ea9170f9p17a92ejsn59b549cc619d',
    'X-RapidAPI-Host': 'hotels-com-provider.p.rapidapi.com'
  };

  var response = await http.get(
    Uri.parse('https://hotels-com-provider.p.rapidapi.com/v2/hotels/search?region_id=$regionId&locale=en_GB&checkin_date=2024-09-26&checkout_date=2024-09-27&sort_order=REVIEW&adults_number=1&domain=AE&children_ages=4,0,15&lodging_type=HOTEL,HOSTEL,APART_HOTEL&price_min=10&star_rating_ids=3,4,5&meal_plan=FREE_BREAKFAST&page_number=1&price_max=500&amenities=WIFI,PARKING&payment_type=PAY_LATER,FREE_CANCELLATION&guest_rating_min=8&available_filter=SHOW_AVAILABLE_ONLY'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    var decodedResponse = jsonDecode(response.body);
    var properties = decodedResponse['properties'] as List<dynamic>; // Corrected path to properties

    

    setState(() {
      hotels = properties.map((hotel) {
        return {
          'name': hotel['name'],
          'id': hotel['id'],
          'price': hotel['price']['options'][0]['formattedDisplayPrice'] ?? 'N/A', 
          'rating': hotel['star'], 
          'image': hotel['propertyImage']['image']['url'],
          'longitude': hotel['mapMarker']['latLong']['longitude'],
          'latitude': hotel['mapMarker']['latLong']['latitude']
        };
      }).toList();
    });
  } else {
    print('Failed to load hotels: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}



double getNormalizedRating(dynamic rating) {
  if (rating == null) {
    return 0.0; // Default rating if none provided
  } else if (rating is int) {
    return rating.toDouble(); // Convert integer to double
  } else if (rating is double) {
    return rating; // Use double directly
  } else {
    return 0.0; // Return default if the type is neither int nor double
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Hotel Booking'),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // Change this color to match your theme
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Enter a location',
                labelStyle: TextStyle(
                  fontSize: 16, // Set the size as per your design
                  color: Colors.grey[600], // Adjust the color to match your theme
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: Colors.blue), // Adjust icon color to match your theme
                  onPressed: () => fetchRegionId(_locationController.text),
                ),
                filled: true,
                fillColor: Colors.transparent, // Keep it transparent to let the container's color show
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none, // No border
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Adjust padding to change the field's height
              ),
              onSubmitted: (value) {
                fetchRegionId(value);
              },
            ),
          ),
        ),
        Expanded( // Ensure the ListView is wrapped in an Expanded widget
          child: ListView.builder(
            itemCount: hotels.length,
            itemBuilder: (context, index) {
              var hotel = hotels[index];
              return buildHotelCard(hotel);
            },
          ),
        ),
      ],
    ),
  );
}

Widget buildHotelCard(dynamic hotel) {
  return Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hotel['image'] != null)
          Image.network(
            hotel['image'],
            width: double.infinity,
            fit: BoxFit.cover,
            height: 200,
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive, 
            shouldLoop: false, 
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ], // Custom colors
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            hotel['name'],
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive, 
            shouldLoop: false, 
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ], // Custom colors
          ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: RatingBarIndicator(
            rating: getNormalizedRating(hotel['rating']),
            itemBuilder: (context, index) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            itemCount: 5,
            itemSize: 20.0,
            direction: Axis.horizontal,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Price: ${hotel['price']}',
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  _confettiController.play();
                  addHotelToGroup(widget.userId, widget.userGroupId,hotel['name'],hotel['latitude'],hotel['longitude'], hotel['rating'], hotel['price'], hotel['image'] );
                },
                child: Text('Book Now'),
              ),
            ),
            ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive, 
            shouldLoop: false, 
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ], // Custom colors
          ),
          ],
        ),
        ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive, 
            shouldLoop: false, 
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ], // Custom colors
          ),
      ],
    ),
  );
}


}
