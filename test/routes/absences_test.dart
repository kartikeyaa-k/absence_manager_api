// File: test/routes/absences_test.dart

import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/absences/index.dart' as absences_route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

void main() {
  late _MockRequestContext context;
  late _MockRequest request;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    context = _MockRequestContext();
    request = _MockRequest();
    when(() => context.request).thenReturn(request);
  });

  group('GET /absences', () {
    test('responds with 200 and valid JSON structure by default', () async {
      // Arrange: no query parameters
      when(() => request.uri).thenReturn(Uri(path: '/absences'));

      // Act
      final response = await absences_route.onRequest(context);

      // Assert
      expect(response.statusCode, equals(HttpStatus.ok));
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;

      // Check the keys exist
      expect(
        body.keys,
        containsAll(<String>['total', 'page', 'limit', 'data']),
      );
      expect(body['total'], isA<int>());
      expect(body['page'], equals(1));
      expect(body['limit'], equals(10));
      expect(body['data'], isA<List<dynamic>>());
    });

    test('applies pagination query parameters correctly', () async {
      when(() => request.uri).thenReturn(
        Uri(path: '/absences', queryParameters: {'page': '2', 'limit': '1'}),
      );

      final response = await absences_route.onRequest(context);
      expect(response.statusCode, equals(HttpStatus.ok));

      final body = jsonDecode(await response.body()) as Map<String, dynamic>;
      expect(body['page'], equals(2));
      expect(body['limit'], equals(1));
      expect((body['data'] as List).length, equals(1));
    });

    test('returns empty data list if page out of range', () async {
      when(() => request.uri).thenReturn(
        Uri(path: '/absences', queryParameters: {'page': '999', 'limit': '10'}),
      );

      final response = await absences_route.onRequest(context);
      expect(response.statusCode, equals(HttpStatus.ok));

      final body = jsonDecode(await response.body()) as Map<String, dynamic>;
      expect(body['data'], isEmpty);
    });

    test('returns 500 when data file is missing', () async {
      final file = File('data/absences.json');
      final backup = File('data/absences.json.bak');
      await file.rename(backup.path);

      when(() => request.uri).thenReturn(Uri(path: '/absences'));

      final response = await absences_route.onRequest(context);

      // Restore the file
      await backup.rename(file.path);

      expect(response.statusCode, equals(HttpStatus.internalServerError));
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;
      expect(body['error'], contains('not found'));
    });
  });
}
