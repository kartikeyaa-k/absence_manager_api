import 'dart:developer';

import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return (context) async {
    final stopwatch = Stopwatch()..start();
    final request = context.request;

    log('[→] ${request.method} ${request.uri.path}');

    final response = await handler(context);

    stopwatch.stop();
    log('[←] ${request.method} ${request.uri.path} • ${response.statusCode} • ${stopwatch.elapsedMilliseconds}ms');

    return response;
  };
}
