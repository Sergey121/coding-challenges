import 'dart:async';
import 'dart:convert';

import 'package:challenge_02_dart/store.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

final router = Router()
  ..post('/', _handlePost)
  ..get('/<name>', _handleGet);

Store store = Store();

Future<Response> _handlePost(Request request) async {
  String data = await request.readAsString();

  var params = JsonDecoder().convert(data);

  String? url = params['url'];

  if (url == null || url.isEmpty) {
    return Response.badRequest(body: 'Missing "url" parameter');
  }

  var response = store.addURL(url);

  return Response.ok(
      jsonEncode(
        response,
      ),
      headers: {'Content-Type': 'application/json'});
}

Future<Response> _handleGet(Request request) async {
  final String? name = request.params['name'];

  if (name == null) {
    return Response.notFound('Not Found');
  }

  var response = store.getURL(name);

  if (response == null) {
    return Response.notFound('Not Found');
  }

  return Response.found(response.url);
}
