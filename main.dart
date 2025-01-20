import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MarkingApp());

class MarkingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marking AI Tool',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MarkingForm(),
    );
  }
}

class MarkingForm extends StatefulWidget {
  @override
  _MarkingFormState createState() => _MarkingFormState();
}

class _MarkingFormState extends State<MarkingForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _criteriaController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();
  final TextEditingController _studentAnswerController =
      TextEditingController();

  String? _feedback;
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // API call
        final response = await http.post(
          Uri.parse(
              'http://10.0.2.2:8000/gradeAnswer'), // Replace with actual endpoint
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'question_text': _questionController.text,
            'marking_criteria': _criteriaController.text,
            'marks_allocation': int.parse(_marksController.text),
            'student_response': _studentAnswerController.text,
          }),
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          setState(() {
            _feedback = result['feedback'];
          });
        } else {
          throw Exception('Failed to retrieve feedback');
        }
      } catch (e) {
        setState(() {
          _feedback = 'An error occurred: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Marking Tool'),
      ),
      body: SingleChildScrollView(
        // Wrap the entire form in a scrollable view
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _questionController,
                  decoration: InputDecoration(labelText: 'Question Text'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the question text';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _criteriaController,
                  decoration: InputDecoration(labelText: 'Marking Criteria'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the marking criteria';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _marksController,
                  decoration: InputDecoration(labelText: 'Marks Allocation'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        int.tryParse(value) == null) {
                      return 'Please enter a valid number for marks';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _studentAnswerController,
                  decoration: InputDecoration(labelText: 'Student Answer'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the student\'s answer';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitForm,
                        child: Text('Submit'),
                      ),
                SizedBox(height: 20),
                if (_feedback != null) ...[
                  Text(
                    'Feedback:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(_feedback!),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to signup page or perform desired CTA action
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SignupPage(), // Define your SignupPage widget
                        ),
                      );
                    },
                    child: Text('Sign Up for Full Marking.ai'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _criteriaController.dispose();
    _marksController.dispose();
    _studentAnswerController.dispose();
    super.dispose();
  }
}

// Dummy SignupPage
class SignupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up for Marking.ai'),
      ),
      body: Center(
        child: Text('Signup page content goes here'),
      ),
    );
  }
}
