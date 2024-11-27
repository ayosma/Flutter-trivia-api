import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final List<int> userAnswers;

  const SummaryScreen({
    Key? key,
    required this.score,
    required this.totalQuestions,
    required this.userAnswers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Summary')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Your Score: $score/$totalQuestions',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: userAnswers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Question ${index + 1}'),
                    trailing: Icon(
                      userAnswers[index] == 1 ? Icons.check : Icons.close,
                      color: userAnswers[index] == 1 ? Colors.green : Colors.red,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to setup screen
              },
              child: Text('Retake Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}