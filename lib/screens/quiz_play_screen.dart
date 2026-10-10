import 'package:flutter/material.dart';

import '../ads/ad_service.dart';
import '../data/content_repository.dart';
import '../data/progress_store.dart';
import '../models/body_system.dart';
import 'quiz_result_screen.dart';

/// A question with its answer options in shuffled order.
class _Item {
  final QuizQuestion question;
  final List<String> options;
  final int correct;
  const _Item(this.question, this.options, this.correct);
}

List<_Item> _buildItems(BodySystem system) {
  final questions = [...system.quiz]..shuffle();
  return questions.map((q) {
    final order = List<int>.generate(q.options.length, (i) => i)..shuffle();
    final options = order.map((i) => q.options[i]).toList();
    return _Item(q, options, order.indexOf(q.answerIndex));
  }).toList();
}

/// Plays one quiz: shows a question at a time with instant feedback.
class QuizPlayScreen extends StatefulWidget {
  final SystemSummary summary;

  const QuizPlayScreen({super.key, required this.summary});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  late Future<BodySystem> _future;
  List<_Item>? _items;
  int _current = 0;
  int? _selected;
  int _score = 0;
  final Set<int> _hidden = {};
  bool _hintUsed = false;

  @override
  void initState() {
    super.initState();
    _future = ContentRepository.instance.loadSystem(widget.summary.id);
  }

  void _select(int i) {
    if (_selected != null) return;
    final item = _items![_current];
    setState(() {
      _selected = i;
      if (i == item.correct) _score++;
    });
  }

  Future<void> _next(BodySystem system) async {
    final total = _items!.length;
    if (_current < total - 1) {
      setState(() {
        _current++;
        _selected = null;
        _hidden.clear();
        _hintUsed = false;
      });
      return;
    }
    await ProgressStore.instance.record(system.id, _score, total);
    if (!mounted) return;
    await AdService.instance.showInterstitialIfDue();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => QuizResultScreen(
          summary: widget.summary,
          score: _score,
          total: total,
        ),
      ),
    );
  }

  /// Rewarded ad: removes two wrong answers for the current question.
  Future<void> _useHint(_Item item) async {
    final shown = await AdService.instance.showRewarded(onReward: () {
      if (!mounted) return;
      final wrong = <int>[
        for (var i = 0; i < item.options.length; i++)
          if (i != item.correct) i
      ]..shuffle();
      setState(() {
        _hidden.addAll(wrong.take(2));
        _hintUsed = true;
      });
    });
    if (!shown && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No ad available right now. Try again later.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.summary.name)),
      body: FutureBuilder<BodySystem>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load this quiz.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final system = snapshot.data!;
          _items ??= _buildItems(system);
          return _buildQuestion(context, system);
        },
      ),
    );
  }

  Widget _buildQuestion(BuildContext context, BodySystem system) {
    final theme = Theme.of(context);
    final items = _items!;
    final item = items[_current];
    final answered = _selected != null;
    final isLast = _current == items.length - 1;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Question ${_current + 1} of ${items.length}',
            style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_current + (answered ? 1 : 0)) / items.length,
        ),
        const SizedBox(height: 20),
        Text(item.question.question, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        for (var i = 0; i < item.options.length; i++)
          if (!_hidden.contains(i))
            _OptionCard(
              text: item.options[i],
              answered: answered,
              isCorrect: i == item.correct,
              isSelected: i == _selected,
              onTap: () => _select(i),
            ),
        if (!answered && !_hintUsed && item.options.length > 2)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _useHint(item),
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('Remove 2 wrong answers (watch an ad)'),
            ),
          ),
        if (answered) ...[
          const SizedBox(height: 8),
          Card(
            color: theme.colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selected == item.correct ? 'Correct!' : 'Not quite.',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(item.question.explanation),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => _next(system),
            child: Text(isLast ? 'See results' : 'Next question'),
          ),
        ],
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String text;
  final bool answered;
  final bool isCorrect;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.text,
    required this.answered,
    required this.isCorrect,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color? border;
    Widget? trailing;
    if (answered && isCorrect) {
      border = Colors.green;
      trailing = const Icon(Icons.check_circle, color: Colors.green);
    } else if (answered && isSelected) {
      border = scheme.error;
      trailing = Icon(Icons.cancel, color: scheme.error);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: border ?? Colors.transparent,
            width: 2,
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(text),
          trailing: trailing,
          onTap: answered ? null : onTap,
        ),
      ),
    );
  }
}
