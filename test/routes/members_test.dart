import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/members/index.dart' as members_route;

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

  group('GET /members', () {
    test('returns 200 with full member list', () async {
      // Arrange
      when(() => request.uri).thenReturn(Uri(path: '/members'));

      // Act
      final response = await members_route.onRequest(context);

      // Assert
      expect(response.statusCode, equals(HttpStatus.ok));
      final body = jsonDecode(await response.body()) as List<dynamic>;
      expect(body, isNotEmpty);

      // Verify first item has expected fields
      final first = body.first as Map<String, dynamic>;
      expect(
        first.keys,
        containsAll(<String>['userId', 'name', 'id', 'crewId', 'image']),
      );
    });

    test('returns 500 when file is missing', () async {
      // Arrange: rename file out of the way
      final file = File('data/members.json');
      final backup = File('data/members.json.bak');
      await file.rename(backup.path);

      when(() => request.uri).thenReturn(Uri(path: '/members'));

      // Act
      final response = await members_route.onRequest(context);

      // Cleanup: restore file
      await backup.rename(file.path);

      // Assert
      expect(response.statusCode, equals(HttpStatus.internalServerError));
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;
      expect(body['error'], contains('members.json not found'));
    });

    test('returns 500 on invalid JSON', () async {
      // Arrange: overwrite file with bad JSON
      final file = File('data/members.json');
      final backup = File('data/members.json.bak');
      await file.rename(backup.path);
      await file.writeAsString('{ invalid json }');

      when(() => request.uri).thenReturn(Uri(path: '/members'));

      // Act
      final response = await members_route.onRequest(context);

      // Cleanup: restore original file
      await file.delete();
      await backup.rename(file.path);

      // Assert
      expect(response.statusCode, equals(HttpStatus.internalServerError));
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;
      expect(body['error'], contains('Failed to load members'));
    });
  });
}
