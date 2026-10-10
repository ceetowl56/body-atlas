import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SystemProgress {
  final int bestPercent;
  final int attempts;

  const SystemProgress({required this.bestPercent, required this.attempts});

  static const empty = SystemProgress(bestPercent: 0, attempts: 0);
}

/// Saves quiz results on the device (best score and attempts per system).
class ProgressStore extends ChangeNotifier {
  ProgressStore._();
  static final ProgressStore instance = ProgressStore._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> _p() async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<SystemProgress> get(String systemId) async {
    final p = await _p();
    return SystemProgress(
      bestPercent: p.getInt('best_$systemId') ?? 0,
      attempts: p.getInt('attempts_$systemId') ?? 0,
    );
  }

  Future<Map<String, SystemProgress>> getAll(List<String> ids) async {
    final result = <String, SystemProgress>{};
    for (final id in ids) {
      result[id] = await get(id);
    }
    return result;
  }

  Future<void> record(String systemId, int correct, int total) async {
    final p = await _p();
    final percent = total == 0 ? 0 : ((correct * 100) / total).round();
    final best = p.getInt('best_$systemId') ?? 0;
    final attempts = p.getInt('attempts_$systemId') ?? 0;
    if (percent > best) await p.setInt('best_$systemId', percent);
    await p.setInt('attempts_$systemId', attempts + 1);
    notifyListeners();
  }
}
