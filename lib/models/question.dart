class Question {
  final String question;
  final List<String> incorrectAnswers;
  final String correctAnswer;
  final String difficulty;
  final String type;

  Question({
    required this.question,
    required this.incorrectAnswers,
    required this.correctAnswer,
    required this.difficulty,
    required this.type,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    List<String> incorrectAnswers = List<String>.from(json['incorrect_answers']);
    return Question(
      question: json['question'],
      incorrectAnswers: incorrectAnswers,
      correctAnswer: json['correct_answer'],
      difficulty: json['difficulty'],
      type: json['type'],
    );
  }
}
