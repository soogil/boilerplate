import 'package:boilerplate/domain/entity/test_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'test_model.freezed.dart';
part 'test_model.g.dart';

//순수 모델
@freezed
@JsonSerializable()
class TestModel with _$TestModel {
  const TestModel({
    required this.id,
  });

  final int id;

  factory TestModel.fromJson(Map<String, dynamic> json) =>
      _$TestModelFromJson(json);
}

extension TestExtension on TestModel {
  TestEntity toEntity() => TestEntity(id: id);
}
