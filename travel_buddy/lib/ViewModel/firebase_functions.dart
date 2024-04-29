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


Future<void> uploadUserData(String username, String age, String gender, String homeLocation, File? image) async {
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
  });
}