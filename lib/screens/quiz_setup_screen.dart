import 'package:flutter/material.dart';
import 'package:quizzer/services/quiz_data.dart';
import '../models/quiz_topic.dart';
import 'quiz_screen.dart';

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  final topicController = TextEditingController();
  QuizType quizType = QuizType.mcq;
  int numberOfQuestions = 5;
  bool isLoading = false;

  void startQuiz() async {
    final topicData = QuizTopic()
      ..topic = topicController.text
      ..quizType = quizType
      ..numberOfQuestions = numberOfQuestions;

    setState(() => isLoading = true);

    try {
      final questions = await getQuizData(topicData);
      setState(() => isLoading = false);

      if (questions.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(questions: questions),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "No questions received. Check the quiz topic and try again.",
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Failed to fetch questions from AI Model. Please try again later.",
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Quizzer")),
      body: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: topicController,
              decoration: InputDecoration(
                labelText: "Enter Topic",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    topicController.clear();
                    setState(() {}); // optional: to rebuild if needed
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<QuizType>(
              value: quizType,
              decoration: InputDecoration(
                labelText: "Select Quiz Type",
                labelStyle: const TextStyle(fontSize: 16),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
              items: QuizType.values.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(
                    e == QuizType.mcq ? "MCQ" : "Fill in the Blank",
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => quizType = val!),
              dropdownColor:
              Theme.of(context).colorScheme.primaryContainer.withOpacity(1),
              icon: Icon(Icons.arrow_drop_down,
                  color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 20),
            Slider(
              value: numberOfQuestions.toDouble(),
              min: 1,
              max: 30,
              divisions: 60,
              label: "$numberOfQuestions",
              onChanged: (val) =>
                  setState(() => numberOfQuestions = val.toInt()),
            ),
            const SizedBox(height: 40),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: startQuiz,
              child: const Text("Start Quiz"),
            ),
          ],
        ),
      ),
    );
  }
}