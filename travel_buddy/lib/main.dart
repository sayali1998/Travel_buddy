import 'package:flutter/material.dart';
import 'package:travel_buddy/View/userLogin.dart';
import 'package:firebase_core/firebase_core.dart';

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
        brightness: Brightness.dark,  // Set the overall brightness to dark
        primaryColor: Colors.deepPurple,  // Primary color for the app
        scaffoldBackgroundColor: Colors.grey[900],  // Background color for major parts of the app
        appBarTheme: AppBarTheme(
          color: Colors.deepPurple,  // Background color for AppBars
          elevation: 4,  // Shadow cast by the AppBar
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.deepPurple,  // Primary color in the color scheme
          secondary: Colors.deepOrange,  // Secondary (accent) color in the color scheme
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.deepPurple,  // Background color of Material buttons
          textTheme: ButtonTextTheme.primary,  // Text theme for buttons based on the brightness
        ),
        textTheme: TextTheme(
          headline1: TextStyle(color: Colors.white),  // Headline styles for better readability on dark background
          bodyText1: TextStyle(color: Colors.white70),  // Body text style
        ),
        inputDecorationTheme: InputDecorationTheme(  // Theme for input fields
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
