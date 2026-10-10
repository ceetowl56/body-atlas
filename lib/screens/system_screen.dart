import 'package:flutter/material.dart';

import '../data/content_repository.dart';
import '../models/body_system.dart';
import 'lesson_screen.dart';

/// Shows the lessons of one body system.
class SystemScreen extends StatefulWidget {
  final SystemSummary summary;

  const SystemScreen({super.key, required this.summary});

  @override
  State<SystemScreen> createState() => _SystemScreenState();
}

class _SystemScreenState extends State<SystemScreen> {
  late Future<BodySystem> _future;

  @override
  void initState() {
    super.initState();
    _future = ContentRepository.instance.loadSystem(widget.summary.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.summary.name)),
      body: FutureBuilder<BodySystem>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load this section.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final system = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                system.summary,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < system.lessons.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      leading: CircleAvatar(child: Text('${i + 1}')),
                      title: Text(system.lessons[i].title),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              LessonScreen(system: system, index: i),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                'For education only. Not medical advice.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }
}
