class Lesson {
  final String title;
  final String body;
  final List<String> keyPoints;

  const Lesson({
    required this.title,
    required this.body,
    required this.keyPoints,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        title: json['title'] as String,
        body: json['body'] as String,
        keyPoints: List<String>.from(json['keyPoints'] as List),
      );
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int answerIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        question: json['question'] as String,
        options: List<String>.from(json['options'] as List),
        answerIndex: json['answerIndex'] as int,
        explanation: json['explanation'] as String,
      );
}

/// Short entry shown in the list of body systems.
class SystemSummary {
  final String id;
  final String name;
  final String icon;
  final String summary;

  const SystemSummary({
    required this.id,
    required this.name,
    required this.icon,
    required this.summary,
  });

  factory SystemSummary.fromJson(Map<String, dynamic> json) => SystemSummary(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        summary: json['summary'] as String,
      );
}

/// A full body system with its lessons and quiz.
class BodySystem {
  final String id;
  final String name;
  final String icon;
  final String summary;
  final List<Lesson> lessons;
  final List<QuizQuestion> quiz;

  const BodySystem({
    required this.id,
    required this.name,
    required this.icon,
    required this.summary,
    required this.lessons,
    required this.quiz,
  });

  factory BodySystem.fromJson(Map<String, dynamic> json) => BodySystem(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        summary: json['summary'] as String,
        lessons: (json['lessons'] as List)
            .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
            .toList(),
        quiz: (json['quiz'] as List)
            .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
