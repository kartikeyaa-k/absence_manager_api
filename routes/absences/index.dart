import 'dart:io';

import 'package:absence_manager_api/src/data/absence_repository.dart';
import 'package:dart_frog/dart_frog.dart';

final _repo = AbsenceRepository();

Future<Response> onRequest(RequestContext context) async {
  // Verify data files exist
  if (!File(_repo.absencesPath).existsSync() ||
      !File(_repo.membersPath).existsSync()) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Required data file(s) missing'},
    );
  }

  try {
    final params = context.request.uri.queryParameters;
    final page = int.tryParse(params['page'] ?? '') ?? 1;
    final limit = int.tryParse(params['limit'] ?? '') ?? 10;
    final userId = int.tryParse(params['userId'] ?? '');

    final result = await _repo.fetchPaginatedEnriched(
      page: page,
      limit: limit,
      userId: userId,
    );

    return Response.json(body: result);
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to load absences'},
    );
  }
}
