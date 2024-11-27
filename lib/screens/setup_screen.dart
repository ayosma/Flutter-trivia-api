// lib/screens/setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_quiz_app/screens/quiz_screen.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  int _numQuestions = 10;
  String _category = '9'; // Default category: General Knowledge
  String _difficulty = 'easy';
  String _type = 'multiple';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Setup')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Number of Questions'),
                keyboardType: TextInputType.number,
                initialValue: '10',
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) => _numQuestions = int.parse(value!),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Category'),
                value: _category,
                items: [
                  DropdownMenuItem(value: '9', child: Text('General Knowledge')),
                  DropdownMenuItem(value: '21', child: Text('Sports')),
                  DropdownMenuItem(value: '11', child: Text('Movies')),
                  // Add more categories as needed
                ],
                onChanged: (value) => setState(() => _category = value!),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Difficulty'),
                value: _difficulty,
                items: [
                  DropdownMenuItem(value: 'easy', child: Text('Easy')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'hard', child: Text('Hard')),
                ],
                onChanged: (value) => setState(() => _difficulty = value!),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Type'),
                value: _type,
                items: [
                  DropdownMenuItem(value: 'multiple', child: Text('Multiple Choice')),
                  DropdownMenuItem(value: 'boolean', child: Text('True/False')),
                ],
                onChanged: (value) => setState(() => _type = value!),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          numQuestions: _numQuestions,
                          category: _category,
                          difficulty: _difficulty,
                          type: _type,
                        ),
                      ),
                    );
                  }
                },
                child: Text('Start Quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
