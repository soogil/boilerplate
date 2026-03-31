#!/usr/bin/env dart
// 사용법:
//   dart run init_project.dart "앱 이름" com.company.appname project_name
//
// 예시:
//   dart run init_project.dart "My App" com.example.myapp my_app

import 'dart:io';

Future<void> main(List<String> args) async {
  if (args.length < 3) {
    _usage();
    exit(1);
  }

  final appName = args[0];
  final bundleId = args[1];
  final projectName = args[2];

  // 유효성 검사
  if (!bundleId.contains('.')) {
    _err('번들 ID는 "com.company.app" 형식이어야 합니다.');
    exit(1);
  }
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(projectName)) {
    _err('프로젝트 이름은 소문자/숫자/밑줄만 사용 가능합니다. (예: my_app)');
    exit(1);
  }
  if (!File('pubspec.yaml').existsSync()) {
    _err('pubspec.yaml이 없습니다. 프로젝트 루트에서 실행하세요.');
    exit(1);
  }

  _log('🚀 Flutter project initialization started...');
  _log('   App Name    : $appName');
  _log('   Bundle ID   : $bundleId');
  _log('   Package Name: $projectName');
  _log('');

  // 1. 앱 이름 / 번들 ID 변경 (rename 패키지)
  await _step('앱 이름 변경', () => _run('dart', ['run', 'rename', 'setAppName', '--value', appName]));
  await _step('번들 ID 변경', () => _run('dart', ['run', 'rename', 'setBundleId', '--value', bundleId]));

  // 2. pubspec.yaml (name / description)
  await _step('pubspec.yaml 업데이트', () async {
    final file = File('pubspec.yaml');
    var content = file.readAsStringSync();
    content = content.replaceFirst(RegExp(r'^name:.*$', multiLine: true), 'name: $projectName');
    content = content.replaceFirst(RegExp(r'^description:.*$', multiLine: true), 'description: "$appName"');
    file.writeAsStringSync(content);
  });

  // 3. Dart import 경로 일괄 변경 (package:boilerplate/ → package:{projectName}/)
  await _step('Dart import 경로 업데이트', () async {
    const oldPkg = 'boilerplate';
    for (final dirName in ['lib', 'test', 'integration_test']) {
      final dir = Directory(dirName);
      if (!dir.existsSync()) continue;
      await for (final entity in dir.list(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final src = entity.readAsStringSync();
        final dst = src.replaceAll('package:$oldPkg/', 'package:$projectName/');
        if (src != dst) {
          entity.writeAsStringSync(dst);
          _log('   Updated: ${entity.path}');
        }
      }
    }
  });

  // 4. Android 패키지 설정
  await _step('Android 패키지 설정', () async {
    final kotlinRoot = Directory('android/app/src/main/kotlin');
    final javaRoot = Directory('android/app/src/main/java');

    final Directory androidRoot;
    final bool useKotlin;

    if (kotlinRoot.existsSync()) {
      androidRoot = kotlinRoot;
      useKotlin = true;
    } else if (javaRoot.existsSync()) {
      androidRoot = javaRoot;
      useKotlin = false;
    } else {
      throw Exception('Android source root를 찾을 수 없습니다 (kotlin/java).');
    }

    final ext = useKotlin ? 'kt' : 'java';
    final targetDir = Directory('${androidRoot.path}/${bundleId.replaceAll('.', '/')}');
    targetDir.createSync(recursive: true);

    // 기존 MainActivity 이동
    final mainFileName = 'MainActivity.$ext';
    final targetFile = File('${targetDir.path}/$mainFileName');
    final oldMain = _findFile(androidRoot, mainFileName);
    if (oldMain != null && oldMain.path != targetFile.path) {
      oldMain.copySync(targetFile.path);
      oldMain.deleteSync();
    }

    // MainActivity 재작성
    final mainContent = useKotlin
        ? 'package $bundleId\n\nimport io.flutter.embedding.android.FlutterActivity\n\nclass MainActivity: FlutterActivity() {\n}\n'
        : 'package $bundleId;\n\nimport io.flutter.embedding.android.FlutterActivity;\n\npublic class MainActivity extends FlutterActivity {\n}\n';
    targetFile.writeAsStringSync(mainContent);

    // AndroidManifest.xml 패치
    final manifest = File('android/app/src/main/AndroidManifest.xml');
    if (manifest.existsSync()) {
      final m = manifest.readAsStringSync().replaceAll(
        RegExp(r'android:name="[^"]*MainActivity"'),
        'android:name=".MainActivity"',
      );
      manifest.writeAsStringSync(m);
    }

    // build.gradle applicationId / namespace 패치
    final gradle = File('android/app/build.gradle');
    if (gradle.existsSync()) {
      var g = gradle.readAsStringSync();
      g = g.replaceAll(RegExp(r'applicationId\s*=\s*"[^"]+"'), 'applicationId = "$bundleId"');
      g = g.replaceAll(RegExp(r'namespace\s*=\s*"[^"]+"'), 'namespace = "$bundleId"');
      gradle.writeAsStringSync(g);
    }
  });

  // 5. flutter clean & pub get
  await _step('flutter clean', () => _run('flutter', ['clean']));
  await _step('flutter pub get', () => _run('flutter', ['pub', 'get']));

  _log('');
  _log('🎉 초기화 완료!');
  _log('   App Name    : $appName');
  _log('   Bundle ID   : $bundleId');
  _log('   Package Name: $projectName');
  _log('');
  _log('다음 단계:');
  _log('  flutter pub run build_runner build --delete-conflicting-outputs');
}

// ── helpers ──────────────────────────────────────────────────────────────────

File? _findFile(Directory dir, String name) {
  try {
    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .firstWhere((f) => f.uri.pathSegments.last == name);
  } catch (_) {
    return null;
  }
}

void _log(String msg) => stdout.writeln(msg);
void _err(String msg) => stderr.writeln('❌ $msg');

void _usage() {
  stderr.writeln('사용법: dart run init_project.dart "앱이름" com.company.appname project_name');
  stderr.writeln('예시:  dart run init_project.dart "My App" com.example.myapp my_app');
}

Future<void> _step(String name, Future<void> Function() action) async {
  stdout.write('⏳ $name...');
  try {
    await action();
    stdout.writeln('\r✅ $name            ');
  } catch (e) {
    stdout.writeln('\r❌ $name 실패');
    rethrow;
  }
}

Future<void> _run(String executable, List<String> args) async {
  final result = await Process.run(
    executable,
    args,
    runInShell: true,
    stdoutEncoding: systemEncoding,
    stderrEncoding: systemEncoding,
  );
  if (result.exitCode != 0) {
    throw Exception(
      '$executable ${args.join(' ')} 실패 (exit ${result.exitCode})\n${result.stderr}',
    );
  }
}
