import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreItemList extends StatefulWidget {
  final String city; 
  const FirestoreItemList({Key? key, required this.city}) : super(key: key);

  @override
  _FirestoreItemListState createState() => _FirestoreItemListState();
}

class _FirestoreItemListState extends State<FirestoreItemList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('HiddenGem').where('city', isEqualTo: widget.city.toLowerCase()).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No items found');
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var item = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return buildItemCard(item);
          },
        );
      },
    );
  }

  Widget buildItemCard(Map<String, dynamic> item) {
    return InkWell(
      onTap: () {
        // add to group in firebase
      },
      child: Card(
        child: Column(
          children: [
            Image.network(
              item['image_url'] ?? 'assets/destination.png',
              width: 160,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/destination.png', width: 160, height: 120, fit: BoxFit.cover);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                item['name'] ?? 'No name available',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
