import 'package:flutter/material.dart';

import '../data/content_repository.dart';
import '../models/body_system.dart';
import 'lesson_screen.dart';

class _Hit {
  final BodySystem system;
  final int index;
  const _Hit(this.system, this.index);
}

/// Search across the titles, text and key points of all lessons.
class LessonSearchDelegate extends SearchDelegate<void> {
  final ContentRepository repo;
  late final Future<List<BodySystem>> _all = repo.loadAll();

  LessonSearchDelegate(this.repo)
      : super(searchFieldLabel: 'Search lessons (e.g. valve)');

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Clear',
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return const Center(child: Text('Type a word to search the lessons.'));
    }
    return FutureBuilder<List<BodySystem>>(
      future: _all,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Search is unavailable.'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final hits = <_Hit>[];
        for (final system in snapshot.data!) {
          for (var i = 0; i < system.lessons.length; i++) {
            final l = system.lessons[i];
            final text =
                '${l.title} ${l.body} ${l.keyPoints.join(' ')}'.toLowerCase();
            if (text.contains(q)) hits.add(_Hit(system, i));
          }
        }
        if (hits.isEmpty) {
          return const Center(child: Text('No lessons found.'));
        }
        return ListView.builder(
          itemCount: hits.length,
          itemBuilder: (context, i) {
            final h = hits[i];
            return ListTile(
              title: Text(h.system.lessons[h.index].title),
              subtitle: Text(h.system.name),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      LessonScreen(system: h.system, index: h.index),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
