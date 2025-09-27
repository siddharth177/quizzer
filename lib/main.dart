import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:quizzer/services/quiz_data.dart';
import 'models/quiz.dart';
import 'models/quiz_topic.dart';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Quiz App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const QuizSetupScreen(),
    );
  }
}

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

  Future<List<Quiz>> fetchQuestions(QuizTopic topicData) async {
    List<Quiz> quizzes = [];
    int batches = (topicData.numberOfQuestions / 10).ceil();

    for (int i = 0; i < batches; i++) {
      int batchCount = (topicData.numberOfQuestions - quizzes.length >= 10)
          ? 10
          : (topicData.numberOfQuestions - quizzes.length);

      final data = await getQuizData(topicData);


        final content = data["choices"][0]["message"]["content"];

        try {
          quizzes.addAll(Quiz.listFromJson(content));
        } catch (e) {
          print("Error parsing quiz JSON: $e");
        }
    }
    return quizzes;
  }

  void startQuiz() async {
    final topicData = QuizTopic()
      ..topic = topicController.text
      ..quizType = quizType
      ..numberOfQuestions = numberOfQuestions;

    setState(() => isLoading = true);
    final questions = await fetchQuestions(topicData);
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
        const SnackBar(content: Text("No questions received.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup Quiz")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: topicController,
              decoration: const InputDecoration(labelText: "Enter Topic"),
            ),
            DropdownButton<QuizType>(
              value: quizType,
              onChanged: (val) => setState(() => quizType = val!),
              items: QuizType.values.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e == QuizType.mcq ? "MCQ" : "Fill in the Blank"),
                );
              }).toList(),
            ),
            Slider(
              value: numberOfQuestions.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              label: "$numberOfQuestions",
              onChanged: (val) =>
                  setState(() => numberOfQuestions = val.toInt()),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                onPressed: startQuiz, child: const Text("Start Quiz")),
          ],
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final List<Quiz> questions;
  const QuizScreen({super.key, required this.questions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentIndex = 0;
  bool? isCorrect;

  void checkAnswer(String answer) {
    final correctAnswer = widget.questions[currentIndex].answer;
    setState(() {
      isCorrect = (answer.toLowerCase() == correctAnswer.toLowerCase());
    });
  }

  void nextQuestion() {
    if (currentIndex < widget.questions.length - 1) {
      setState(() {
        currentIndex++;
        isCorrect = null;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ResultScreen(total: widget.questions.length),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text("Question ${currentIndex + 1}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(q.question,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ...q.options.map((opt) {
                  return ListTile(
                    title: Text(opt.option),
                    onTap: () => checkAnswer(opt.option),
                    trailing: isCorrect == null
                        ? null
                        : (opt.option == q.answer
                        ? const Icon(Icons.check, color: Colors.green)
                        : (isCorrect == false &&
                        opt.option != q.answer
                        ? const Icon(Icons.close, color: Colors.red)
                        : null)),
                  );
                }),
                const SizedBox(height: 20),
                if (isCorrect != null)
                  ElevatedButton(
                      onPressed: nextQuestion,
                      child: Text(currentIndex ==
                          widget.questions.length - 1
                          ? "Finish"
                          : "Next"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int total;
  const ResultScreen({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Result")),
      body: Center(
        child: Text("Quiz Finished! You attempted $total questions."),
      ),
    );
  }
}