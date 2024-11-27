import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_quiz_app/models/question.dart';

class ApiService {
  static const String baseUrl = 'https://opentdb.com/api.php';

  String _constructUrl({
    required int amount,
    required String category,
    required String difficulty,
    required String type,
  }) {
    return '$baseUrl?amount=$amount&category=$category&difficulty=$difficulty&type=$type';
  }

  Future<List<Question>> fetchQuestions({
    required int amount,
    required String category,
    required String difficulty,
    required String type,
  }) async {
    final url = _constructUrl(
      amount: amount,
      category: category,
      difficulty: difficulty,
      type: type,
    );

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['results'];
      return data.map((question) => Question.fromJson(question)).toList();
    } else {
      throw Exception('Failed to load questions');
    }
  }
}
