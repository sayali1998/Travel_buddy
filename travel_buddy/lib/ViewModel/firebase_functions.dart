import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

    
Future<UserCredential> signInWithEmailPassword(String email, String password) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  return await auth.signInWithEmailAndPassword(email: email, password: password);
}

Future<UserCredential> registerWithEmailPassword(String email, String password) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  return await auth.createUserWithEmailAndPassword(email: email, password: password);
}


Future<String?> uploadImage(File image, String uuid) async {
  File? fileToUpload = image;
  String filePath = 'profile_images/${uuid}/${DateTime.now().millisecondsSinceEpoch}_${fileToUpload.path.split('/').last}';
  try 
  {
    UploadTask task = FirebaseStorage.instance.ref(filePath).putFile(fileToUpload);
    TaskSnapshot snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  } catch (e) {
    print('Failed to upload image: ${e.toString()}');
    return null;
  }
}

Future<Map<String, dynamic>?> fetchUserData(String userID) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    DocumentSnapshot userDoc = await firestore.collection('users').doc(userID).get();

    if (userDoc.exists) {
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      return userData;
    } else {
      print('No user found for the given userID');
      return null;
    }
  } catch (e) {
    print('Error fetching user data: $e');
    return null;
  }
}

Future<void> uploadUserData(String username, String age, String gender, String homeLocation, File? image, String email) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? currentUser = auth.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String? imageUrl = await uploadImage(image!, currentUser!.uid);
  final storageRef = FirebaseStorage.instance.ref().child('user_profiles/${currentUser.uid}');
  await storageRef.putFile(image);
  imageUrl = await storageRef.getDownloadURL();

  await firestore.collection('users').doc(currentUser.uid).set({
    'username': username,
    'age': age,
    'gender': gender,
    'homeLocation': homeLocation,
    'profileImageUrl': imageUrl,
    'email': email,
  });
}


Future<List<Map<String, dynamic>>> fetchUserGroups(String userId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> userGroups = [];

  try {
    QuerySnapshot querySnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('UserGroups')
        .get();
    for (var doc in querySnapshot.docs) {
      userGroups.add(doc.data() as Map<String, dynamic>);
    }
  } catch (e) {
    print('Error fetching wishlist: $e');
  }

  return userGroups;
}


Future<String> addGroup({required String groupName, required String budget, DateTime? startDate, DateTime? endDate, }) async {
    DocumentReference groupRef = await FirebaseFirestore.instance.collection('groups').add({
      'name': groupName,
      'budget': budget,
      'startDate': startDate,
      'endDate': endDate,
    });
    return groupRef.id;
  }

Future<List<String>> getUserIdsByEmails(List<String> emails, String userId) async {
  List<String> userIds = [];
  for (String email in emails) {
    var usersSnapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();
    for (var doc in usersSnapshot.docs) {
      userIds.add(doc.id);
    }
  }
  userIds.add(userId);
  return userIds;
}


Future<void> addHotelToGroup(String userId, String groupID, String hotelName, double latitude, double longitude, double rating, String price, String image) async {
  Query userGroups = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('UserGroups')
      .where('groupId', isEqualTo: groupID);

  final querySnapshot = await userGroups.get();
  DocumentSnapshot groupDoc = querySnapshot.docs.first;

  CollectionReference hotelBookings = groupDoc.reference.collection('HotelBookings');

  return await hotelBookings.add({
    'name': hotelName, 
    'latitude': latitude, 
    'longitude': longitude,
    'rating': rating,
    'price': price,
    'image_url': image
  }).then((DocumentReference doc) {
    print('Hotel booking added with ID: ${doc.id}');
  }).catchError((e) {
    print('Error adding hotel booking: $e');
  });
}




Future<void> addUsersToGroup(String groupId, List<String> userEmails, String groupName, String userID) async {
    List<String> userIds = await getUserIdsByEmails(userEmails, userID);

    await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
      'users': FieldValue.arrayUnion(userIds)
    });

  for (String userId in userIds) {
    await FirebaseFirestore.instance.collection('users').doc(userId).collection('UserGroups').doc(groupId).set({
      'groupId': groupId,
      'groupName': groupName, 
    });
  }
}

Future<Map<String, dynamic>?> fetchGroupDetailsForUser(String userId, String groupId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    DocumentSnapshot groupSnapshot = await firestore.collection('groups').doc(groupId).get();
    if (!groupSnapshot.exists) {
      print('No general group details found for the given groupId');
      return null;
    }

    QuerySnapshot hotelBookingsSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('UserGroups')
        .doc(groupId)
        .collection('HotelBookings')
        .get();
    
    List<Map<String, dynamic>> hotelBookings = [];
    for (var doc in hotelBookingsSnapshot.docs) {
      hotelBookings.add(doc.data() as Map<String, dynamic>);
    }

    Map<String, dynamic> groupDetails = groupSnapshot.data() as Map<String, dynamic>;
    groupDetails['hotelBookings'] = hotelBookings; 
    return groupDetails;
  } catch (e) {
    print('Error fetching group details: $e');
    return null;
  }
}


Future<void> uploadHiddenGem({
  required File image,
  required String city,
  required String gemName,
}) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  String imagePath = 'hidden_gems/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
  try {
    UploadTask uploadTask = storage.ref(imagePath).putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();

    await firestore.collection('HiddenGem').add({
      'name': gemName,
      'image_url': imageUrl,
      'city': city.toLowerCase()
    });
    print('Hidden Gem uploaded successfully');
  } catch (e) {
    print('Failed to upload Hidden Gem: ${e.toString()}');
  }
}


Future<void> addDestination(String groupId, String placeName) async {
  print("Attempting to add destination. Group ID: $groupId, Place Name: $placeName");
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference places = firestore.collection('groups').doc(groupId).collection('places');
    await places.add({
      'name': placeName,
    });
  } catch (e) {
    print('Failed to add destination: $e');
  }
}

