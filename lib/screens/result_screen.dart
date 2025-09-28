import 'package:flutter/material.dart';
import '../models/quiz.dart';

class ResultScreen extends StatelessWidget {
  final int total;
  final int attempted;
  final int correct;
  final int incorrect;
  final List<Quiz> questions;
  final Map<int, String> userAnswers;

  const ResultScreen({
    super.key,
    required this.total,
    required this.attempted,
    required this.correct,
    required this.incorrect,
    required this.questions,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Results")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text("Total Questions: $total",
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text("Attempted: $attempted",
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text("Correct: $correct",
                        style: const TextStyle(
                            fontSize: 18, color: Colors.green)),
                    const SizedBox(height: 8),
                    Text("Wrong: $incorrect",
                        style:
                        const TextStyle(fontSize: 18, color: Colors.red)),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final q = questions[index];
                  final userAns = userAnswers[index];
                  final isCorrect = userAns != null &&
                      userAns.trim().toLowerCase() ==
                          q.answer.trim().toLowerCase();

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Q${index + 1}. ${q.question}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Your Answer: ${userAns ?? "Not Attempted"}",
                            style: TextStyle(
                              fontSize: 15,
                              color: userAns == null
                                  ? Colors.grey
                                  : (isCorrect ? Colors.green : Colors.red),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Correct Answer: ${q.answer}",
                            style: const TextStyle(
                                fontSize: 15, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}