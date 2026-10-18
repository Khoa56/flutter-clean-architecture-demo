import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Kiểm tra dependency từ import/export, không chỉ nhìn cấu trúc thư mục.
void main() {
  final directive = RegExp(r'''(?:import|export)\s+['"]([^'"]+)['"]''');
  List<File> filesIn(String layer) => Directory('lib/features/posts/$layer')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();

  test('Domain chỉ dùng Dart SDK và các file của chính Domain', () {
    for (final file in filesIn('domain')) {
      for (final match in directive.allMatches(file.readAsStringSync())) {
        final uri = match.group(1)!;
        if (uri.startsWith('dart:')) continue;
        expect(
          uri.startsWith('package:'),
          isFalse,
          reason: '${file.path}: $uri',
        );
        final resolved = file.uri.resolve(uri).path;
        expect(resolved, contains('/domain/'), reason: '${file.path}: $uri');
      }
    }
  });
  test('Presentation không import Data, HTTP hoặc composition root', () {
    for (final file in filesIn('presentation')) {
      for (final match in directive.allMatches(file.readAsStringSync())) {
        final uri = match.group(1)!;
        expect(uri, isNot(contains('/data/')), reason: file.path);
        expect(uri, isNot(contains('core/di')), reason: file.path);
        expect(uri, isNot(contains('get_it')), reason: file.path);
        expect(uri, isNot(contains('package:http/')), reason: file.path);
      }
    }
  });
  test('Data không phụ thuộc Presentation hoặc Flutter', () {
    for (final file in filesIn('data')) {
      for (final match in directive.allMatches(file.readAsStringSync())) {
        final uri = match.group(1)!;
        expect(uri, isNot(contains('/presentation/')), reason: file.path);
        expect(uri, isNot(startsWith('package:flutter/')), reason: file.path);
      }
    }
  });
}
