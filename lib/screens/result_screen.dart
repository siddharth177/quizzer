import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final int total;
  final int attempted;
  final int correct;

  const ResultScreen({
    super.key,
    required this.total,
    required this.attempted,
    required this.correct,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Result")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Total Questions: $total",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Attempted: $attempted",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Correct: $correct",
                style: const TextStyle(fontSize: 18, color: Colors.green)),
            const SizedBox(height: 10),
            Text("Wrong: ${attempted - correct}",
                style: const TextStyle(fontSize: 18, color: Colors.red)),
          ],
        ),
      ),
    );
  }
}