import 'package:flutter/material.dart';
import '../models/quiz.dart';
import 'result_screen.dart';

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
      isCorrect =
      (answer.trim().toLowerCase() == correctAnswer.trim().toLowerCase());
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
          builder: (context) => ResultScreen(total: widget.questions.length),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[currentIndex];
    final isMcq = q.options.isNotEmpty;
    final answerController = TextEditingController();

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
                Text(
                  q.question,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // MCQ UI
                if (isMcq)
                  ...q.options.map((opt) {
                    return ListTile(
                      title: Text(opt.option),
                      onTap: () => checkAnswer(opt.option),
                      trailing: isCorrect == null
                          ? null
                          : (opt.option == q.answer
                          ? const Icon(Icons.check, color: Colors.green)
                          : (isCorrect == false && opt.option != q.answer
                          ? const Icon(Icons.close, color: Colors.red)
                          : null)),
                    );
                  }),

                // Fill-in-the-blank UI
                if (!isMcq)
                  Column(
                    children: [
                      TextField(
                        controller: answerController,
                        decoration: const InputDecoration(
                          labelText: "Type your answer",
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (val) {
                          checkAnswer(val);
                        },
                      ),
                      const SizedBox(height: 10),
                      if (isCorrect != null)
                        ElevatedButton(
                          onPressed: () {
                            answerController.clear();
                            nextQuestion();
                          },
                          child: Text(currentIndex ==
                              widget.questions.length - 1
                              ? "Finish"
                              : "Next"),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}