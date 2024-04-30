import 'package:flutter/material.dart';
import 'package:travel_buddy/View/custom_view/wishlistItem.dart';
import 'package:travel_buddy/ViewModel/firebase_functions.dart'; 

class WishlistScreen extends StatefulWidget {
  final String userId; 

  WishlistScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  Future<List<Map<String, dynamic>>>? wishlistFuture;

  @override
  void initState() {
    super.initState();
    wishlistFuture = fetchWishlist(widget.userId); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: wishlistFuture, // Use the future obtained from fetchWishlist
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading wishlist: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView(
              children: snapshot.data!.map((item) {
                return WishlistItem(
                  item: item['username'],
                  details: item['message'],
                  imageUrl: item['imageUrl'],
                );
              }).toList(),
            );
          } else {
            return Center(child: Text("No items added to wishlist"));
          }
        },
      ),
    );
  }
}
