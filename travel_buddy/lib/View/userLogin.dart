import 'package:flutter/material.dart';
import 'package:travel_buddy/View/home.dart';
import 'package:travel_buddy/View/register.dart';
import 'package:travel_buddy/ViewModel/firebase_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<UserLogin> createState() => UserLoginPage();
}

class UserLoginPage extends State<UserLogin> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        UserCredential userCredential = await signInWithEmailPassword(_email, _password);
        Navigator.pushReplacement(context, 
            MaterialPageRoute(builder: (context) => HomePage(userId: userCredential.user!.uid)));
      } on FirebaseAuthException catch (e) {
        _showErrorDialog(e.message ?? 'Login failed');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An Error Occurred'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void registerScreen(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView( 
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Image.asset('assets/destination.png', width: 100, height: 100),
                SizedBox(height: 40),
                Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@')) {
                  return 'Please enter a valid email address.';
                }
                _email = value;
                return null;
              },
              onSaved: (value) => _email = value!,

                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                if (value == null || value.isEmpty || value.length < 6) { 
                  return 'Password must be at least 6 characters long.';
                }
                _password = value;
                return null;
              },
              onSaved: (value) => _password = value!,

                      ),
                      SizedBox(height: 30),
                      _isLoading
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, 
                                backgroundColor: Theme.of(context).primaryColor,
                                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ),
                      SizedBox(height: 15),
                      TextButton(
                        onPressed: registerScreen ,
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                        ),
                        child: Text('New User? Register Here'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


