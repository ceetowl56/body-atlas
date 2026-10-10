import 'package:flutter/material.dart';

import '../data/content_repository.dart';
import '../data/progress_store.dart';
import '../models/body_system.dart';
import '../utils/icon_map.dart';
import 'quiz_play_screen.dart';

class _QuizListData {
  final List<SystemSummary> systems;
  final Map<String, SystemProgress> progress;
  const _QuizListData(this.systems, this.progress);
}

/// Quiz tab: choose a body system to be quizzed on.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<_QuizListData> _future;

  Future<_QuizListData> _load() async {
    final systems = await ContentRepository.instance.loadIndex();
    final progress = await ProgressStore.instance
        .getAll(systems.map((s) => s.id).toList());
    return _QuizListData(systems, progress);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: FutureBuilder<_QuizListData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load quizzes.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.systems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final s = data.systems[i];
              final p = data.progress[s.id] ?? SystemProgress.empty;
              return Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(child: Icon(iconFor(s.icon))),
                  title: Text(s.name),
                  subtitle: Text(p.attempts == 0
                      ? 'Not taken yet'
                      : 'Best score: ${p.bestPercent}%'),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => QuizPlayScreen(summary: s),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
