import 'package:flutter/material.dart';

import '../data/content_repository.dart';
import '../models/body_system.dart';
import '../utils/icon_map.dart';
import 'lesson_search.dart';
import 'system_screen.dart';

/// Lists all body systems. Tap one to see its lessons.
class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final _repo = ContentRepository.instance;
  late Future<List<SystemSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.loadIndex();
  }

  void _retry() {
    setState(() {
      _future = _repo.loadIndex();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search lessons',
            onPressed: () => showSearch<void>(
              context: context,
              delegate: LessonSearchDelegate(_repo),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<SystemSummary>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not load lessons.'),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _retry, child: const Text('Try again')),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final s = items[i];
              return Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(child: Icon(iconFor(s.icon))),
                  title: Text(s.name),
                  subtitle: Text(s.summary),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SystemScreen(summary: s),
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
