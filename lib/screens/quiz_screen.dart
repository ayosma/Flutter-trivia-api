import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

import 'summary_screen.dart';

class Question {
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  final List<String> allOptions;

  Question({
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
    required this.allOptions,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    // Decode HTML entities
    String decodeHtml(String text) {
      return parse(text).body?.text ?? text;
    }

    List<String> incorrectAnswers = (json['incorrect_answers'] as List)
        .map((answer) => decodeHtml(answer))
        .toList();
    
    final correctAnswer = decodeHtml(json['correct_answer']);
    
    List<String> allOptions = [...incorrectAnswers, correctAnswer]..shuffle();

    return Question(
      question: decodeHtml(json['question']),
      correctAnswer: correctAnswer,
      incorrectAnswers: incorrectAnswers,
      allOptions: allOptions,
    );
  }
}

class ApiService {
  Future<List<Question>> fetchQuestions({
    required int amount,
    required String category,
    required String difficulty,
    required String type,
  }) async {
    final response = await http.get(
      Uri.parse('https://opentdb.com/api.php?amount=$amount&category=$category&difficulty=$difficulty&type=$type'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (data['response_code'] == 0) {
        return (data['results'] as List)
            .map((questionJson) => Question.fromJson(questionJson))
            .toList();
      } else {
        throw Exception('No questions found');
      }
    } else {
      throw Exception('Failed to load questions');
    }
  }
}

class QuizScreen extends StatefulWidget {
  final int numQuestions;
  final String category;
  final String difficulty;
  final String type;

  const QuizScreen({
    Key? key,
    required this.numQuestions,
    required this.category,
    required this.difficulty,
    required this.type,
  }) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<Question>> _questionsFuture;
  List<Question>? _questions;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  String? _selectedAnswer;
  String _feedback = '';
  bool _timeUp = false;
  late Timer _timer;
  int _timeRemaining = 15;

  @override
  void initState() {
    super.initState();
    _questionsFuture = ApiService().fetchQuestions(
      amount: widget.numQuestions,
      category: widget.category,
      difficulty: widget.difficulty,
      type: widget.type,
    );
  }

  void _startTimer() {
    _timeRemaining = 15;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeRemaining--;
        });

        if (_timeRemaining <= 0) {
          timer.cancel();
          _handleTimeUp();
        }
      }
    });
  }

  void _handleTimeUp() {
    if (!_isAnswered) {
      setState(() {
        _timeUp = true;
        _isAnswered = true;
        _feedback = 'Time\'s up! The correct answer was: ${_questions![_currentQuestionIndex].correctAnswer}';
      });
    }
  }

  void _answerQuestion(String selectedAnswer) {
    if (_isAnswered || _timeUp) return;

    _timer.cancel();

    setState(() {
      _isAnswered = true;
      _selectedAnswer = selectedAnswer;

      if (selectedAnswer == _questions![_currentQuestionIndex].correctAnswer) {
        _score++;
        _feedback = 'Correct!';
      } else {
        _feedback = 'Incorrect! The correct answer was: ${_questions![_currentQuestionIndex].correctAnswer}';
      }
    });
  }

  void _nextQuestion() {
  if (_currentQuestionIndex + 1 < widget.numQuestions) {
    setState(() {
      _currentQuestionIndex++;
      _isAnswered = false;
      _selectedAnswer = null;
      _feedback = '';
      _timeUp = false;
    });
    _startTimer();
  } else {
    // Create a list to track user answers
    List<int> userAnswers = _questions!.map((question) {
      if (_selectedAnswer == question.correctAnswer) {
        return 1; // Correct answer
      } else {
        return 0; // Incorrect answer
      }
    }).toList();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryScreen(
          score: _score,
          totalQuestions: widget.numQuestions,
          userAnswers: userAnswers, // Add this line
        ),
      ),
    );
  }
}
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Score: $_score',
                style: TextStyle(fontSize: 18),
              ),
            ),
          )
        ],
      ),
      body: FutureBuilder<List<Question>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading questions: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No questions available'));
          }

          // Initialize questions on first successful load
          _questions ??= snapshot.data;

          // Start timer for first question
          if (_currentQuestionIndex == 0 && !_isAnswered) {
            _startTimer();
          }

          final currentQuestion = _questions![_currentQuestionIndex];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Indicator
                Text(
                  'Question ${_currentQuestionIndex + 1}/${widget.numQuestions}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / widget.numQuestions,
                ),
                SizedBox(height: 16),

                // Question Text
                Text(
                  currentQuestion.question,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),

                // Countdown Timer
                Text(
                  'Time Remaining: $_timeRemaining seconds',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),

                // Answer Options
                ...currentQuestion.allOptions.map((option) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isAnswered
                            ? (option == currentQuestion.correctAnswer
                                ? Colors.green
                                : (_selectedAnswer == option
                                    ? Colors.red
                                    : null))
                            : null,
                      ),
                      onPressed: _isAnswered || _timeUp
                          ? null
                          : () => _answerQuestion(option),
                      child: Text(option),
                    ),
                  );
                }).toList(),

                SizedBox(height: 16),

                // Feedback Text
                Text(
                  _feedback,
                  style: TextStyle(
                    color: _feedback.contains('Correct!')
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Next Question Button
                if (_isAnswered || _timeUp)
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    child: Text(_currentQuestionIndex + 1 < widget.numQuestions
                        ? 'Next Question'
                        : 'Finish Quiz'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}