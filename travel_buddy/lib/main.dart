import 'package:flutter/material.dart';
import 'package:travel_buddy/View/userLogin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Buddy',
      theme: ThemeData(
        brightness: Brightness.dark,  
        primaryColor: Colors.deepPurple,  
        scaffoldBackgroundColor: Colors.grey[900], 
        appBarTheme: const AppBarTheme(
          color: Colors.deepPurple,  
          elevation: 4,  
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurple, 
          secondary: Colors.deepOrange,  
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.deepPurple,  
          textTheme: ButtonTextTheme.primary,  
        ),
        inputDecorationTheme: const InputDecorationTheme( 
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepOrange),
          ),
          labelStyle: TextStyle(color: Colors.deepOrange),
        ),
        useMaterial3: true,  
      ),
      home: const UserLogin(title: "Login")
    );
  }
}
