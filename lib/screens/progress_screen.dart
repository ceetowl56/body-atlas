import 'package:flutter/material.dart';

import '../ads/privacy_settings_button.dart';
import '../data/content_repository.dart';
import '../data/progress_store.dart';
import '../models/body_system.dart';
import '../utils/icon_map.dart';

class _ProgressData {
  final List<SystemSummary> systems;
  final Map<String, SystemProgress> progress;
  const _ProgressData(this.systems, this.progress);
}

/// Progress tab: best score and attempts for each body system.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Future<_ProgressData> _future;

  Future<_ProgressData> _load() async {
    final systems = await ContentRepository.instance.loadIndex();
    final progress = await ProgressStore.instance
        .getAll(systems.map((s) => s.id).toList());
    return _ProgressData(systems, progress);
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _future = _load();
    });
  }

  @override
  void initState() {
    super.initState();
    _future = _load();
    ProgressStore.instance.addListener(_reload);
  }

  @override
  void dispose() {
    ProgressStore.instance.removeListener(_reload);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: FutureBuilder<_ProgressData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load progress.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          final totalAttempts =
              data.progress.values.fold<int>(0, (sum, p) => sum + p.attempts);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                totalAttempts == 0
                    ? 'Take a quiz to see your progress here.'
                    : 'Quizzes completed: $totalAttempts',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              for (final s in data.systems)
                Builder(builder: (context) {
                  final p = data.progress[s.id] ?? SystemProgress.empty;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(iconFor(s.icon)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(s.name,
                                      style: theme.textTheme.titleMedium),
                                ),
                                Text('${p.bestPercent}%'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: p.bestPercent / 100,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              p.attempts == 0
                                  ? 'Not taken yet'
                                  : 'Attempts: ${p.attempts}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              const PrivacySettingsButton(),
            ],
          );
        },
      ),
    );
  }
}
