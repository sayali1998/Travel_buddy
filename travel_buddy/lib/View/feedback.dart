import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

  

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _reviewController = TextEditingController();
  String _placePhotoUrl = '';
  final String placeName = 'Watkins Glen'; // This can be dynamic based on user selection
  final String placeLocation = 'New York'; // This too can be dynamic
  final double placeRating = 4.5; // Usually you'd calculate this from reviews

  @override
  void initState() {
    super.initState();
    _fetchPlacePhoto();
  }

  Future<void> _fetchPlacePhoto() async {
    // ... Add your _fetchPlacePhoto implementation here
    // (The method from the previous response)
  }

  void _submitReview() async {
    final String reviewText = _reviewController.text;
    if (reviewText.isNotEmpty) {
      // ... Add your _submitReview implementation here
      // (The method from the previous response)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lake View'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _placePhotoUrl.isNotEmpty
                ? Image.network(_placePhotoUrl, height: 250, fit: BoxFit.cover)
                : SizedBox(height: 250, child: Center(child: CircularProgressIndicator())), // Placeholder widget while image loads
            SizedBox(height: 10),
            Text(
              placeName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(placeLocation, style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                SizedBox(width: 4),
                Text('$placeRating', style: TextStyle(fontSize: 18)),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Watkins Glen State Park truly shines from July to August, when the waterfalls and greenery are at their peak...',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Leave a review...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _submitReview,
                child: Text('Submit Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
