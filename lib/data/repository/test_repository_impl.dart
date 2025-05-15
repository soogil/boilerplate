import 'package:boilerplate/core/api/test_api.dart';
import 'package:boilerplate/domain/repository/test_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


final testRepository = Provider<Future<TestRepository>>((ref) async {
  final api = await ref.read(testApiProvider);
  return TestRepositoryImpl(api);
});

// 모델에서 엔티티로 변환 로직 및 인터페이스 구체적 구현
class TestRepositoryImpl extends TestRepository {
  TestRepositoryImpl(this._api);

  final TestApi _api;
}