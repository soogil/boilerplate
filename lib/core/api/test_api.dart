import 'package:riverpod_annotation/riverpod_annotation.dart';


final testApiProvider = Provider<Future<TestApi>>((ref) async {
  return TestApi();
});

// rest 통신 api
class TestApi {
}