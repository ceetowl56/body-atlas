import 'package:flutter/material.dart';

import '../models/body_system.dart';
import 'quiz_play_screen.dart';

/// Shows the score after a quiz.
class QuizResultScreen extends StatelessWidget {
  final SystemSummary summary;
  final int score;
  final int total;

  const QuizResultScreen({
    super.key,
    required this.summary,
    required this.score,
    required this.total,
  });

  String get _message {
    final percent = total == 0 ? 0 : score * 100 / total;
    if (percent == 100) return 'Perfect score!';
    if (percent >= 75) return 'Great job!';
    if (percent >= 50) return 'Good effort. Review the lessons and try again.';
    return 'Keep learning. Read the lessons and try again.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = total == 0 ? 0 : ((score * 100) / total).round();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(summary.name, style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              Text('$percent%', style: theme.textTheme.displayLarge),
              const SizedBox(height: 8),
              Text('$score of $total correct'),
              const SizedBox(height: 12),
              Text(_message, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => QuizPlayScreen(summary: summary),
                  ),
                ),
                child: const Text('Try again'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
                child: const Text('Back to quizzes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
