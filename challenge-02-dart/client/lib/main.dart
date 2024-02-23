import 'package:flutter/services.dart';
import 'package:client/shortened_url.dart';
import 'package:flutter/material.dart';

import 'short_url_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URL Shortener',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _shortUrlController;
  String? errorText;
  ShortenedURL? _shortenedURL;

  final ShortURLService _shortURLService = ShortURLService();

  @override
  void initState() {
    super.initState();
    _shortUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _shortUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(Icons.link),
                    Text('Shorten a long url'),
                  ],
                ),
              ),
              TextField(
                controller: _shortUrlController,
                onChanged: _handleChangeShortUrl,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Enter a long url',
                  errorText: errorText,
                ),
              ),
              if (_shortenedURL != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                  child: TextField(
                    controller: TextEditingController()
                      ..text = _shortenedURL!.shortURL,
                    readOnly: true,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: _handleCopyShortUrl,
                      ),
                      labelText: 'Your short url',
                      filled: true,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ElevatedButton(
                    onPressed: _handlePressSubmit, child: const Text('Submit')),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _handlePressSubmit() async {
    final url = _shortUrlController.text;

    if (url.isEmpty) {
      setState(() {
        errorText = 'The url cannot be empty';
      });
      return;
    }

    if (!Uri.parse(url).isAbsolute) {
      setState(() {
        errorText = 'Please enter a valid url';
      });
      return;
    }

    setState(() {
      _shortenedURL = null;
    });

    try {
      ShortenedURL res = await _shortURLService.createShortURL(url);
      setState(() {
        _shortenedURL = res;
      });
    } on FormatException catch (e) {
      setState(() {
        errorText = e.message;
      });
    } catch (e) {
      setState(() {
        errorText = e.toString();
      });
    }
  }

  void _handleChangeShortUrl(String value) {
    if (errorText != null) {
      setState(() {
        errorText = null;
      });
    }
  }

  void _handleCopyShortUrl() {
    if (_shortenedURL != null) {
      Clipboard.setData(ClipboardData(text: _shortenedURL!.shortURL));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }
}
