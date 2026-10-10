import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/body_system.dart';

/// Loads lessons and quizzes from the JSON files in assets/data/.
/// To add a new body system: add assets/data/<id>.json and list it in
/// assets/data/index.json. No code changes needed.
class ContentRepository {
  ContentRepository._();
  static final ContentRepository instance = ContentRepository._();

  final Map<String, BodySystem> _cache = {};
  List<SystemSummary>? _index;

  Future<List<SystemSummary>> loadIndex() async {
    if (_index != null) return _index!;
    final raw = await rootBundle.loadString('assets/data/index.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    _index = (data['systems'] as List)
        .map((e) => SystemSummary.fromJson(e as Map<String, dynamic>))
        .toList();
    return _index!;
  }

  Future<BodySystem> loadSystem(String id) async {
    final cached = _cache[id];
    if (cached != null) return cached;
    final raw = await rootBundle.loadString('assets/data/$id.json');
    final system =
        BodySystem.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    _cache[id] = system;
    return system;
  }

  Future<List<BodySystem>> loadAll() async {
    final index = await loadIndex();
    return Future.wait(index.map((s) => loadSystem(s.id)));
  }
}
