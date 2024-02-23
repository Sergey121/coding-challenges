class ShortenedURL {
  String key;
  String url;
  String shortURL;

  ShortenedURL(this.key, this.url, this.shortURL);

  ShortenedURL.fromJson(Map<String, dynamic> json)
      : key = json['key'],
        url = json['url'],
        shortURL = json['shortURL'];
}
