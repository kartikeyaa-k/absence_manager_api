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
    test('filters by userId and applies pagination', () async {
      const userId = 2664;
      when(() => request.uri).thenReturn(
        Uri(
          path: '/absences',
          queryParameters: {
            'userId': '$userId',
            'page': '1',
            'limit': '10',
          },
        ),
      );

      final response = await absences_route.onRequest(context);

      expect(response.statusCode, equals(HttpStatus.ok));
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;

      expect(body.keys, containsAll(['total', 'page', 'limit', 'data']));
      expect(body['page'], equals(1));
      expect(body['limit'], equals(10));

      final data = body['data'] as List<dynamic>;
      expect(data, isNotEmpty);

      for (final item in data.cast<Map<String, dynamic>>()) {
        expect(item['userId'], equals(userId));
        expect(item, contains('memberName'));
        expect(item, contains('memberImage'));
      }

      // Verify sorting ascending by startDate
      final dates =
          // ignore: avoid_dynamic_calls
          data.map((d) => DateTime.parse(d['startDate'].toString())).toList();
      for (int i = 1; i < dates.length; i++) {
        expect(
          dates[i].isAfter(dates[i - 1]) ||
              dates[i].isAtSameMomentAs(dates[i - 1]),
          isTrue,
        );
      }
    });

    test('returns empty list when userId not found', () async {
      when(() => request.uri).thenReturn(
        Uri(
          path: '/absences',
          queryParameters: {
            'userId': '999999',
            'page': '1',
            'limit': '10',
          },
        ),
      );

      final response = await absences_route.onRequest(context);
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;

      expect(response.statusCode, equals(HttpStatus.ok));
      expect(body['total'], equals(0));
      expect(body['data'], isEmpty);
    });

    test('returns paginated result without filters', () async {
      when(() => request.uri).thenReturn(
        Uri(
          path: '/absences',
          queryParameters: {
            'page': '1',
            'limit': '5',
          },
        ),
      );

      final response = await absences_route.onRequest(context);
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;

      expect(response.statusCode, equals(HttpStatus.ok));
      expect(body['page'], equals(1));
      expect(body['limit'], equals(5));
      expect(body['data'], isA<List<dynamic>>());
    });
  });
}
