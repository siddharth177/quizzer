import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizzer/models/quiz.dart';
import 'package:quizzer/models/quiz_topic.dart';

Future<List<Quiz>> getQuizData(QuizTopic quizTopic) async {
  String kGroqApiKey =
      'Bearer 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';
  final aiModels = [
    "openai/gpt-oss-120b",
    "meta-llama/llama-4-maverick-17b-128e-instruct",
    "gemma2-9b-it",
    "qwen/qwen3-32b",
  ];

  final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
  final headers = {
    'Authorization': kGroqApiKey,
    'Content-Type': 'application/json',
  };

  for (var model in aiModels) {
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final body = json.encode({
          "messages": [
            {
              "role": "system",
              "content":
                  "you are quiz questions provider. in the prompt you will get three things. \n1. topic on which you need to prepare quiz. \n2. number of questions you need to prepare. \n3. type of questions (MCQ or Fill in the blank). In case of MCQ questions, for each question produce 4 options. \n\nYour response will contain a json array of the following format. And always send complete json array. \n1. In case of mcq questions\n[\n{\n'question': \n'options': [\n{\n'option': 'option text'\n'status': true\n},\n{\n'option': 'option text'\n'status': false\n}\n]\n}\n]\n\nin case of not MCQ \n[\n{\n'question': \n'answer': 'answer text'\n]\n}\n]\n",
            },
            {"role": "user", "content": quizTopic.toString()},
          ],
          "model": model,
          "temperature": 1,
          "max_tokens": 8192,
          "top_p": 1,
          "stream": false,
          "response_format": {"type": "json_object"},
          "stop": null,
        });

        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          dynamic content = responseData['choices'][0]['message']['content'];
          if (content is String) {
            final decoded = json.decode(content);
            if (decoded is List) {
              return decoded.map((e) => Quiz.fromJson(e)).toList();
            }
          } else if (content is List) {
            return content.map((e) => Quiz.fromJson(e)).toList();
          }
        }
      } catch (e) {
        print(e);
      }
    }
  }
  throw Exception('failed to get quiz data from any of the AI models');
}
