import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:body_atlas/models/body_system.dart';

void main() {
  final index = jsonDecode(File('assets/data/index.json').readAsStringSync())
      as Map<String, dynamic>;

  for (final entry in index['systems'] as List) {
    final id = (entry as Map<String, dynamic>)['id'] as String;
    test('$id content is valid', () {
      final json = jsonDecode(File('assets/data/$id.json').readAsStringSync())
          as Map<String, dynamic>;
      final system = BodySystem.fromJson(json);
      expect(system.lessons, isNotEmpty);
      expect(system.quiz, isNotEmpty);
      for (final q in system.quiz) {
        expect(q.answerIndex, inInclusiveRange(0, q.options.length - 1));
      }
    });
  }
}
