import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio.g.dart';

@riverpod
Dio dioClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.example.com', // TODO: 실제 API base URL
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // 필요하다면 Interceptor 추가
  // dio.interceptors.add(LogInterceptor(responseBody: true));

  return dio;
}