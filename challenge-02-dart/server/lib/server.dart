import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

final router = Router()..post('/', _handlePost);

Response _handlePost(Request request) {
  return Response.ok('Hello, World!\n');
}
