import 'dart:convert';
import 'package:crypto/crypto.dart';
import './shortened_url.dart';

class Store {
  static final Store _store = Store._internal();

  factory Store() {
    return _store;
  }

  Store._internal();

  String _name = 'Store';

  String get name => _name;

  // Key value list of shortened urls
  Map<String, ShortenedURL> _urls = {};

  ShortenedURL? getURL(String key) {
    return _urls[key];
  }

  ShortenedURL addURL(String url) {
    String key = _generateHashKey(url);
    if (_urls.containsKey(key)) {
      return _urls[key]!;
    }
    ShortenedURL shortenedURL =
        ShortenedURL(key, url, 'http://localhost:8080/$key');
    _urls[key] = shortenedURL;
    return shortenedURL;
  }

  String _generateHashKey(String url) {
    var bytes = utf8.encode(url);
    var digest = sha1.convert(bytes);
    return digest.toString().substring(0, 5);
  }
}
