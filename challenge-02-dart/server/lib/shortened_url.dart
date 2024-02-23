class ShortenedURL {
  String key;
  String url;
  String shortURL;

  ShortenedURL(this.key, this.url, this.shortURL);

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'url': url,
      'shortURL': shortURL,
    };
  }
}
