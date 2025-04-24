import 'package:dart_frog/dart_frog.dart';
import 'cors.dart';
import 'logger.dart';

Handler middleware(Handler handler) {
  return handler.use(cors()).use(logger());
}
