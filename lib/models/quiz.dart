import 'dart:convert';

class Quiz {
  String question;
  List<Option> options;
  String answer;

  Quiz({required this.question, required this.options, required this.answer});

  factory Quiz.fromJson(Map<String, dynamic> json) {
    String correctAnswer = '';
    if (json.containsKey('options') && json['options'] is List) {
      var optionsList = json['options'] as List;
      var correctOption = optionsList.firstWhere(
        (opt) => opt is Map<String, dynamic> && opt['status'] == 'correct',
        orElse: () => null,
      );
      if (correctOption != null) {
        correctAnswer = correctOption['option'];
      }
    } else if (json.containsKey('answer')) {
      correctAnswer = json['answer'];
    }

    return Quiz(
      question: json['question'] ?? '',
      options: json.containsKey('options') && json['options'] is List
          ? Option.listFromJson(json['options'])
          : [],
      answer: correctAnswer,
    );
  }

  static List<Quiz> listFromJson(String jsonString) {
    final data = json.decode(jsonString);
    final List<dynamic> quizList = data['questions'] ?? data;
    return quizList.map((item) => Quiz.fromJson(item)).toList();
  }
}

class Option {
  String option;
  bool isCorrect;

  Option({required this.option, this.isCorrect = false});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      option: json['option'] ?? '',
      isCorrect: json['status'],
    );
  }

  static List<Option> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((item) => Option.fromJson(item)).toList();
  }
}
