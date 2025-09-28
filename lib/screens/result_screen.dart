import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final int total;

  const ResultScreen({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Result")),
      body: Center(
        child: Text(
          "Quiz Finished! You attempted $total questions.",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}