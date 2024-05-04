import 'package:flutter/material.dart';
import 'package:travel_buddy/View/flight_booking.dart';
import 'package:travel_buddy/View/hotel_booking.dart';
import 'package:travel_buddy/View/maps.dart';
import 'package:travel_buddy/ViewModel/firebase_functions.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupDetails extends StatefulWidget {
  final String groupId;
  final String userId;

  GroupDetails({Key? key, required this.groupId, required this.userId}) : super(key: key);

  @override
  _GroupDetailsState createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails> {
  Future<Map<String, dynamic>?>? groupDetails;

  @override
  void initState() {
    super.initState();
    groupDetails = fetchGroupDetailsForUser(widget.userId, widget.groupId);
  }

  void _showBookingOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.flight, color: Colors.blue),
                title: Text('Flight Booking'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FlightBookingPage(userId: widget.userId)),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.hotel, color: Colors.green),
                title: Text('Hotel Booking'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HotelBookingPage(userId: widget.userId, userGroupId: widget.groupId)),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: groupDetails,
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading group details'));
          } else if (snapshot.hasData) {
            Map<String, dynamic>? groupDetails = snapshot.data;
            return ListView(
              padding: EdgeInsets.all(8.0),
              children: [
                Card(
                  elevation: 4.0,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.group, color: Colors.blue),
                        title: Text('Group Name'),
                        subtitle: Text('${groupDetails?['name'] ?? 'N/A'}'),
                      ),
                      ListTile(
                        leading: Icon(Icons.account_balance_wallet, color: Colors.green),
                        title: Text('Budget'),
                        subtitle: Text('\$${groupDetails?['budget'] ?? 'N/A'}'),
                      ),
                      ListTile(
                        leading: Icon(Icons.date_range, color: Colors.orange),
                        title: Text('Start Date'),
                        subtitle: Text('${groupDetails?['startDate']?.toDate().toString() ?? 'N/A'}'),
                      ),
                      ListTile(
                        leading: Icon(Icons.date_range, color: Colors.red),
                        title: Text('End Date'),
                        subtitle: Text('${groupDetails?['endDate']?.toDate().toString() ?? 'N/A'}'),
                      ),
                    ],
                  ),
                ),
                ..._buildHotelBookings(groupDetails),
                ..._buildPlaces(groupDetails),
              ],
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBookingOptions(context),
        tooltip: 'Booking Options',
        child: Icon(Icons.add),
      ),
    );
  }


List<Widget> _buildHotelBookings(Map<String, dynamic>? groupDetails) {
  if (groupDetails?['hotelBookings'] == null) return [];
  return [
    Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Text('Hotel Bookings:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    ),
    ...groupDetails!['hotelBookings'].map<Widget>((booking) {
      return Card(
        elevation: 2.0,
        child: ListTile(
          title: Text(booking['name']),
          subtitle: Text('Rating: ${booking['rating']} | Price: ${booking['price']}'),
          leading: booking['image_url'] != null ? Image.network(booking['image_url'], width: 50, height: 50, fit: BoxFit.cover) : null,
          trailing: IconButton(
            icon: Icon(Icons.directions),
            onPressed: ()  {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapScreen(lat:booking['latitude'], long: booking['longitude'])),
              );
            },
          ),
        ),
      );
    }).toList(),
  ];
}


List<Widget> _buildPlaces(Map<String, dynamic>? groupDetails) {
  if (groupDetails?['placesData'] == null) return [];
  return [
    Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Text('Places Shortlisted:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    ),
    ...groupDetails!['placesData'].map<Widget>((place) {
      return Card(
      elevation: 2.0,
      child: ListTile(
        title: Text(place['name']),
        leading: place['image_url'] != null ? Image.network(place['image_url'], width: 50, height: 50, fit: BoxFit.cover) : null,
        trailing: IconButton(
          icon: Icon(Icons.directions),
          onPressed: ()  {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapScreen(lat:place['latitude'], long: place['longitude'])),
              );
            },
        ),
      ),
    );
  }).toList(),
    
  ];
}




}
