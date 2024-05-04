import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_buddy/View/home.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:travel_buddy/ViewModel/firebase_functions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class UserRegisterScreen extends StatefulWidget {
  final String userId;
  final String username;
  UserRegisterScreen({Key? key, required this.userId, required this.username}) : super(key: key);

  @override
  UserRegister createState() => UserRegister();
}

class UserRegister extends State<UserRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String _username = '';
  String _age = '';
  String _gender = '';
  String _homeLocation = '';

  Future<void> _pickImage() async {
    var status = await Permission.photos.request();  
    print(status);
      try {
        final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        setState(() {
          if (pickedFile != null) {
            _image = File(pickedFile.path);
          } else {
            print('No image selected.');
          }
        });
      } catch (e) {
        print('Failed to pick image: $e');
      }
  }


  Future<void> _loadPlaceholderImage() async {
  final byteData = await rootBundle.load('assets/placeholder_profile.png');
  final file = File('${(await getTemporaryDirectory()).path}/placeholder_profile.png');
  await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  setState(() {
    _image = file;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 100,
                    backgroundImage: _image != null ? FileImage(_image!) : AssetImage('assets/placeholder_profile.png') as ImageProvider,
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                const Text(
                  "Tap on Image to upload new Image",
                  style: TextStyle(
                    fontSize: 10, 
                    color: Colors.black,
                    fontWeight: FontWeight.normal, 
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter your username' : null,
                  onSaved: (value) => _username = value!,
                ),
                SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Age', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Please enter your age' : null,
                  onSaved: (value) => _age = value!,
                ),
                SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter your gender' : null,
                  onSaved: (value) => _gender = value!,
                ),
                SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Home Location', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter your home location' : null,
                  onSaved: (value) => _homeLocation = value!,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      if(_image == null){
                        await _loadPlaceholderImage(); 
                      }
                      uploadUserData(_username, _age, _gender, _homeLocation, _image, widget.username);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(userId: widget.userId ),
                        ),
                      );
                    }
                  },
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
