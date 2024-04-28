import 'package:firebase_auth/firebase_auth.dart';
    
Future<UserCredential> signInWithEmailPassword(String email, String password) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  return await auth.signInWithEmailAndPassword(email: email, password: password);
}

Future<UserCredential> registerWithEmailPassword(String email, String password) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  return await auth.createUserWithEmailAndPassword(email: email, password: password);
}
