import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_buddy/ViewModel/firebase_functions.dart';

class HiddenGem extends StatefulWidget {
  const HiddenGem({Key? key}) : super(key: key);

  @override
  _HiddenGemState createState() => _HiddenGemState();
}

class _HiddenGemState extends State<HiddenGem> {
  final TextEditingController _locationNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  XFile? _imageFile;
  String? _validationError;

  @override
  void dispose() {
    _locationNameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _uploadPicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final File imageFile = File(image.path);

      int fileSize = await imageFile.length();
      if (fileSize > 5000000) {
        setState(() {
          _validationError = "File is too large. Size limit is 5MB.";
          _imageFile = null;
        });
        return;
      }

      if (!['jpg', 'jpeg', 'png'].contains(imageFile.path.split('.').last.toLowerCase())) {
        setState(() {
          _validationError = "Unsupported file type. Only JPG and PNG are allowed.";
          _imageFile = null;
        });
        return;
      }

      setState(() {
        _imageFile = image;
        _validationError = null;
      });
    } else {
      setState(() {
        _validationError = "You must select an image to proceed.";
        _imageFile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Camera Dialog"),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextField(
              controller: _locationNameController,
              decoration: InputDecoration(
                labelText: 'Location Name',
                hintText: 'Enter location name',
              ),
            ),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'City',
                hintText: 'Enter city name',
              ),
            ),
            SizedBox(height: 20),
            _imageFile == null
              ? Text(_validationError ?? "No image selected.")
              : Image.file(File(_imageFile!.path)),
            TextButton(
              child: Text('Upload Picture'),
              onPressed: _uploadPicture,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('OK'),
          onPressed: () {
            if (_imageFile != null && _locationNameController.text.isNotEmpty && _cityController.text.isNotEmpty) {
              Navigator.of(context).pop(); 
              uploadHiddenGem(
                image: File(_imageFile!.path),
                city: _cityController.text,
                gemName: _locationNameController.text
              );
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Error'),
                  content: Text(_validationError ?? 'All fields must be filled to proceed.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

