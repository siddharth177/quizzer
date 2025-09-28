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
  int attempted = 0;
  int correct = 0;

  // Store user answers for fill-in-the-blank
  Map<int, String> userAnswers = {};
  late TextEditingController answerController;

  @override
  void initState() {
    super.initState();
    answerController = TextEditingController();
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  void checkAnswer(String answer) {
    final correctAnswer = widget.questions[currentIndex].answer;
    final isRight =
        (answer.trim().toLowerCase() == correctAnswer.trim().toLowerCase());

    setState(() {
      isCorrect = isRight;
      attempted++;
      if (isRight) correct++;
      userAnswers[currentIndex] = answer; // store user's answer
    });
  }

  void checkMcqAnswer(String answer, bool right) {
    setState(() {
      isCorrect = right;
      attempted++;
      if (right) correct++;
      userAnswers[currentIndex] = answer; // store user's answer
    });
  }

  void nextQuestion() {
    if (currentIndex < widget.questions.length - 1) {
      setState(() {
        currentIndex++;
        isCorrect = null;
        // Load previous answer into controller if exists
        answerController.text = userAnswers[currentIndex] ?? '';
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            total: widget.questions.length,
            attempted: attempted,
            correct: correct,
          ),
        ),
      );
    }
  }

  void previousQuestion() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        isCorrect = null;
        // Load previous answer into controller if exists
        answerController.text = userAnswers[currentIndex] ?? '';
      });
    } else {
      Navigator.pop(context); // exit quiz
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[currentIndex];
    final isMcq = q.options.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text("Question ${currentIndex + 1}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        q.question,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (isMcq)
                        ...q.options.map((opt) {
                          return ListTile(
                            title: Text(opt.option),
                            onTap: () => checkMcqAnswer(opt.option, opt.isCorrect),
                            trailing: isCorrect == null
                                ? null
                                : (opt.isCorrect
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        )
                                      : (isCorrect == false &&
                                                !opt.isCorrect
                                            ? const Icon(
                                                Icons.close,
                                                color: Colors.red,
                                              )
                                            : null)),
                          );
                        }),

                      if (!isMcq)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: answerController,
                              decoration: const InputDecoration(
                                labelText: "Type your answer",
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) {
                                userAnswers[currentIndex] =
                                    val; // store live input
                              },
                              onEditingComplete: () {
                                // Trigger check when user leaves text field
                                final typed = answerController.text;
                                final correctAnswer = q.answer;
                                setState(() {
                                  isCorrect =
                                      typed.trim().toLowerCase() ==
                                      correctAnswer.trim().toLowerCase();
                                });
                              },
                              onSubmitted: (val) {
                                final correctAnswer = q.answer;
                                setState(() {
                                  isCorrect =
                                      val.trim().toLowerCase() ==
                                      correctAnswer.trim().toLowerCase();
                                });
                              },
                            ),
                            const SizedBox(height: 10),

                            // Show the correct answer if user typed anything or isCorrect is set
                            if ((answerController.text.isNotEmpty ||
                                isCorrect != null))
                              Row(
                                children: [
                                  const Text(
                                    "Correct Answer: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    q.answer,
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                  const SizedBox(width: 10),
                                  if (isCorrect != null)
                                    Icon(
                                      isCorrect! ? Icons.check : Icons.close,
                                      color: isCorrect!
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                ],
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.only(top: 26.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: previousQuestion,
                    child: Text(currentIndex == 0 ? "Exit Quiz" : "Previous"),
                  ),
                  ElevatedButton(
                    onPressed: nextQuestion,
                    child: Text(
                      currentIndex == widget.questions.length - 1
                          ? "Submit"
                          : "Next",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
