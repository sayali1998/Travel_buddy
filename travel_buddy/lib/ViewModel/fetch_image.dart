import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> fetchImageUrl(String placeName) async {
    try {
      var response = await http.get(Uri.parse('http://127.0.0.1:5000/search_image?query=$placeName'));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['image_url'];
      } else {
        throw Exception('Failed to load image URL');
      }
    } catch (e) {
      print(e.toString());
      return "assets/destination.png"; 
    }
  }

Future<List<String>> fetchImageUrls(String query) async {
  Uri url = Uri.parse('http://127.0.0.1:5000/search_images?query=$query');
  http.Response response = await http.get(url);

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    List<String> imageUrls = List<String>.from(data['image_urls'].map((item) => item as String));
    return imageUrls;
  } else {
    throw Exception('Failed to load images');
  }
}



