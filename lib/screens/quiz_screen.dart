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

  final Map<int, String> userAnswers = {};
  final Map<int, bool> correctness = {};

  final Map<int, TextEditingController> controllers = {};
  final Map<int, FocusNode> focusNodes = {};

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    for (final f in focusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  void checkAnswer(String answer) {
    final q = widget.questions[currentIndex];

    bool isRight;
    if (q.options.isNotEmpty) {
      final opt = q.options.firstWhere(
            (o) => o.option.trim() == answer.trim(),
        orElse: () => Option(option: answer, isCorrect: false),
      );
      isRight = opt.isCorrect;
    } else {
      isRight = _evaluateFillAnswer(answer, q.answer);
    }

    setState(() {
      userAnswers[currentIndex] = answer;
      correctness[currentIndex] = isRight;
      if (controllers.containsKey(currentIndex)) {
        controllers[currentIndex]!.text = answer;
      }
    });
  }
  bool _evaluateFillAnswer(String user, String correct) {
    final userNum = _parseNumeric(user);
    final correctNum = _parseNumeric(correct);

    if (userNum != null && correctNum != null) {
      return (userNum - correctNum).abs() < 1e-6;
    }

    final a = _normalizeString(user);
    final b = _normalizeString(correct);
    return a == b;
  }

  double? _parseNumeric(String s) {
    if (s.isEmpty) return null;
    var str = s.trim().toLowerCase();

    if (str.startsWith('(') && str.endsWith(')')) {
      str = str.substring(1, str.length - 1).trim();
    }

    if (str.contains('%')) {
      final percentStr = str.replaceAll('%', '').trim();
      final val = double.tryParse(percentStr.replaceAll(',', '.'));
      if (val != null) return val / 100.0;
    }

    if (str.contains('/')) {
      final parts = str.split('/');
      if (parts.length == 2) {
        final num = double.tryParse(parts[0].trim().replaceAll(',', '.'));
        final den = double.tryParse(parts[1].trim().replaceAll(',', '.'));
        if (num != null && den != null && den != 0) return num / den;
      }
    }

    final cleaned = str.replaceAll(',', '.');
    final d = double.tryParse(cleaned);
    if (d != null) return d;

    return null;
  }

  String _normalizeString(String s) {
    return s
        .toLowerCase()
        .replaceAll(RegExp(r'[\s\p{P}\p{S}]', unicode: true), '')
        .trim();
  }

  void goToQuestion(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void finishQuiz() {
    final attempted = userAnswers.length;
    final correct = correctness.values.where((v) => v == true).length;
    final incorrect = attempted - correct;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          total: widget.questions.length,
          attempted: attempted,
          correct: correct,
          incorrect: incorrect,
          questions: widget.questions,
          userAnswers: userAnswers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[currentIndex];
    final isMcq = q.options.isNotEmpty;

    controllers.putIfAbsent(currentIndex, () {
      final c = TextEditingController(text: userAnswers[currentIndex] ?? '');
      return c;
    });

    focusNodes.putIfAbsent(currentIndex, () {
      final fn = FocusNode();
      fn.addListener(() {
        if (!fn.hasFocus) {
          if (!isMcq) {
            final value = controllers[currentIndex]!.text;
            if (value.trim().isNotEmpty) {
              checkAnswer(value);
            }
          }
        }
      });
      return fn;
    });

    controllers[currentIndex]!.text = userAnswers[currentIndex] ?? controllers[currentIndex]!.text;

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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                          final selected = userAnswers[currentIndex] == opt.option;
                          final selCorrect = selected ? (correctness[currentIndex] ?? opt.isCorrect) : null;

                          return ListTile(
                            title: Text(opt.option),
                            onTap: () {
                              checkAnswer(opt.option);
                            },
                            trailing: selected
                                ? (selCorrect == true
                                ? const Icon(Icons.check, color: Colors.green)
                                : const Icon(Icons.close, color: Colors.red))
                                : null,
                          );
                        }),

                      if (!isMcq)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: controllers[currentIndex],
                              focusNode: focusNodes[currentIndex],
                              decoration: const InputDecoration(
                                labelText: "Type your answer",
                                border: OutlineInputBorder(),
                              ),
                              textInputAction: TextInputAction.done,
                              onChanged: (val) {
                                userAnswers[currentIndex] = val;
                              },
                              onSubmitted: (val) {
                                checkAnswer(val);
                                // keep keyboard closed
                                FocusScope.of(context).unfocus();
                              },
                            ),
                            const SizedBox(height: 10),

                            if ((userAnswers[currentIndex]?.trim().isNotEmpty ?? false) ||
                                correctness.containsKey(currentIndex))
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Your Answer: ${userAnswers[currentIndex] ?? ''}",
                                    style: TextStyle(
                                      color: (correctness[currentIndex] == true)
                                          ? Colors.green
                                          : (correctness[currentIndex] == false ? Colors.red : Colors.grey),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Correct Answer: ${q.answer}",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
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

            Padding(
              padding: const EdgeInsets.only(top: 26.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (currentIndex == 0) {
                        Navigator.pop(context);
                      } else {
                        goToQuestion(currentIndex - 1);
                      }
                    },
                    child: Text(currentIndex == 0 ? "Exit Quiz" : "Previous"),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      if (!isMcq) {
                        final val = controllers[currentIndex]!.text;
                        if ((val.trim().isNotEmpty) && !correctness.containsKey(currentIndex)) {
                          checkAnswer(val);
                        }
                      }
                      if (currentIndex == widget.questions.length - 1) {
                        finishQuiz();
                      } else {
                        goToQuestion(currentIndex + 1);
                      }
                    },
                    child: Text(
                      currentIndex == widget.questions.length - 1 ? "Submit" : "Next",
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