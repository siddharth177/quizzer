class QuizTopic {
  String topic = '';
  QuizType quizType = QuizType.mcq;
  int numberOfQuestions = 0;


  @override
  String toString() {
    return "1. $topic \n 2. $numberOfQuestions \n 3. ${quizType == QuizType.mcq ? 'MCQ' : 'Fill-in-the-blank'}";
  }
}

enum QuizType {
  mcq,
  blank;
}