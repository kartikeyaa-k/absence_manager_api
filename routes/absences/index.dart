import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

/// Handles GET /absences?page=<n>&limit=<m>
/// Reads the JSON wrapper from data/absences.json of the form:
/// {
///   "message": "...",
///   "payload": [ { ... }, ... ]
/// }
/// Applies simple offset-based pagination on the payload list and returns:
/// {
///   "total": <totalCount>,
///   "page": <pageNumber>,
///   "limit": <pageSize>,
///   "data": [ ...paginated items... ]
/// }
Future<Response> onRequest(RequestContext context) async {
  final file = File('data/absences.json');

  if (!file.existsSync()) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'absences.json not found'},
    );
  }

  try {
    // Read raw file content
    final content = await file.readAsString();

    // Decode root object
    final Map<String, dynamic> wrapper =
        jsonDecode(content) as Map<String, dynamic>;

    // Extract payload list
    final List<dynamic> rawList = wrapper['payload'] as List<dynamic>;

    // Convert to typed list
    final List<Map<String, dynamic>> allAbsences =
        List<Map<String, dynamic>>.from(rawList);

    // Parse query parameters with sensible defaults
    final params = context.request.uri.queryParameters;
    final page = int.tryParse(params['page'] ?? '') ?? 1;
    final limit = int.tryParse(params['limit'] ?? '') ?? 10;

    final total = allAbsences.length;
    final startIndex = (page - 1) * limit;
    final endIndex = (startIndex + limit).clamp(0, total);

    // Slice out the current page; if startIndex >= total, return empty list
    final List<Map<String, dynamic>> pageData = (startIndex < total)
        ? allAbsences.sublist(startIndex, endIndex)
        : <Map<String, dynamic>>[];

    return Response.json(
      body: {
        'total': total,
        'page': page,
        'limit': limit,
        'data': pageData,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Failed to load absences'},
    );
  }
}
