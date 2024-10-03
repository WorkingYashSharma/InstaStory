import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:story_app/models/user_model.dart';

class ApiService {
  final String apiUrl = 'https://ixifly.in/flutter/task2';

  Future<List<User>> fetchStories() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      // Log the response status and body for debugging
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');  // Log the full response body

      if (response.statusCode == 200) {
        // Decode the response as a map (since it's not a list)
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Print the keys to understand the structure
        print('Response Keys: ${jsonResponse.keys}');

        // Check if there is a 'data' field or something similar containing the list of users
        if (jsonResponse.containsKey('data')) {
          List<dynamic> data = jsonResponse['data'];
          print('User Data: $data');
          return data.map((user) => User.fromJson(user)).toList();
        } else {
          // If there's no 'data' field, log the entire structure for further debugging
          print('No "data" key found in the response.');
          throw Exception('Unexpected API response structure.');
        }
      } else {
        throw Exception('Failed to load stories. Status Code: ${response.statusCode}\nBody: ${response.body}');
      }
    } catch (e) {
      // Print the exception for debugging
      print('Error: $e');
      throw Exception('Error fetching data: $e');
    }
  }
}
