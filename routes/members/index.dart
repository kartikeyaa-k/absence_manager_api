import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

/// Handles GET /members
/// Reads the JSON wrapper from data/members.json of the form:
/// {
///   "message": "...",
///   "payload": [ { ... }, … ]
/// }
/// Returns that payload array directly.
Future<Response> onRequest(RequestContext context) async {
  final file = File('data/members.json');

  if (!file.existsSync()) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'members.json not found'},
    );
  }

  try {
    final content = await file.readAsString();
    final wrapper = jsonDecode(content) as Map<String, dynamic>;
    final List<dynamic> payload = wrapper['payload'] as List<dynamic>;

    return Response.json(
      body: payload,
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to load members'},
    );
  }
}
