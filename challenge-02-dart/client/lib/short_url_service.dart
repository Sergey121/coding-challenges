import 'dart:convert';
import 'package:client/shortened_url.dart';
import 'package:http/http.dart' as http;

class ShortURLService {
  Future<ShortenedURL> createShortURL(String url) async {
    if (url.isEmpty) {
      throw const FormatException('The url cannot be empty');
    }

    if (!Uri.parse(url).isAbsolute) {
      throw const FormatException('Please enter a valid url');
    }

    var response = await http.post(
      Uri.parse('http://localhost:8080'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'url': url}),
    );

    if (response.statusCode == 400) {
      throw FormatException(response.body);
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to create short url');
    }

    return ShortenedURL.fromJson(jsonDecode(response.body));
  }
}
