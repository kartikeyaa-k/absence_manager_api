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
    test('filters by userId when provided, returns all without paging',
        () async {
      // Arrange: pick a known userId from your sample data, e.g., 2664
      const userId = 2664;
      when(() => request.uri).thenReturn(
          Uri(path: '/absences', queryParameters: {'userId': '$userId'}));

      // Act
      final response = await absences_route.onRequest(context);

      // Assert
      expect(response.statusCode, equals(HttpStatus.ok));
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;

      // Should contain only 'total' and 'data'
      expect(body.keys, containsAll(<String>['total', 'data']));
      expect(body.keys, isNot(contains('page')));
      expect(body.keys, isNot(contains('limit')));

      final data = body['data'] as List<dynamic>;
      expect(data, isNotEmpty);
      // Every absence should match the userId filter
      for (final item in data.cast<Map<String, dynamic>>()) {
        expect(item['userId'], equals(userId));
        // Enrichment fields must be present
        expect(item, contains('memberName'));
        expect(item, contains('memberImage'));
      }
      // total should equal the length of data
      expect(body['total'], equals(data.length));
    });

    test('returns empty list when userId not found', () async {
      // Arrange: a userId not in data, e.g., 999999
      when(() => request.uri).thenReturn(
          Uri(path: '/absences', queryParameters: {'userId': '999999'}));

      // Act
      final response = await absences_route.onRequest(context);

      // Assert
      expect(response.statusCode, equals(HttpStatus.ok));
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;
      expect(body['total'], equals(0));
      expect(body['data'], isEmpty);
      // No page/limit fields when filtering by userId
      expect(body.keys, isNot(contains('page')));
      expect(body.keys, isNot(contains('limit')));
    });

    // existing tests for default paging, out-of-range, and missing file...
  });
}
