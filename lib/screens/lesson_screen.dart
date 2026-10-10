import 'package:flutter/material.dart';

import '../ads/ad_service.dart';
import '../models/body_system.dart';

/// Shows one lesson, with Previous / Next buttons.
class LessonScreen extends StatelessWidget {
  final BodySystem system;
  final int index;

  const LessonScreen({super.key, required this.system, required this.index});

  Future<void> _go(BuildContext context, int newIndex) async {
    // Shows an interstitial every few lessons (see AdConfig).
    await AdService.instance.onLessonChange();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => LessonScreen(system: system, index: newIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lesson = system.lessons[index];
    final theme = Theme.of(context);
    final hasPrev = index > 0;
    final hasNext = index < system.lessons.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('${system.name} (${index + 1}/${system.lessons.length})'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(lesson.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(
            lesson.body,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 20),
          Card(
            color: theme.colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Key points', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  for (final p in lesson.keyPoints)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2, right: 8),
                            child: Icon(Icons.check_circle, size: 18),
                          ),
                          Expanded(child: Text(p)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (hasPrev)
                OutlinedButton.icon(
                  onPressed: () => _go(context, index - 1),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
              const Spacer(),
              if (hasNext)
                FilledButton.icon(
                  onPressed: () => _go(context, index + 1),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                )
              else
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
