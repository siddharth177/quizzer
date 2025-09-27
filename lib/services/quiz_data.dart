import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizzer/models/quiz_topic.dart';

Future<Map<String, dynamic>> getQuizData(QuizTopic quizTopic) async {
  String kGroqApiKey = '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';

  final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
  final headers = {
    'Authorization': kGroqApiKey,
    'Content-Type': 'application/json',
  };
  final body = json.encode({
    "messages": [
      {
        "role": "system",
        "content":
            "you are quiz questions provider. in the prompt you will get three things. 1. topic on which you need to prepare quiz. 2. number of questions you need to prepare. 3. type of questions (MCQ or Fill in the blank). In case of MCQ questions, for each question produce 4 options. \n\nYour response will contain a json of the following format\nin case of mcq esutions\n[\n{\n'question': \n'options': [\n{\n'option': 'option text'\n'status': 'correct'\n},\n{\n'option': 'option text'\n'status': 'wrong'\n}\n]\n}\n]\n\nin case of not MCQ \n[\n{\n'question': \n'answer': \n]\n}\n]\n",
      },
      {"role": "user", "content": quizTopic.toString()},
    ],
    "model": "llama-3.3-70b-versatile",
    "temperature": 1,
    "max_tokens": 8192,
    "top_p": 1,
    "stream": false,
    "response_format": {"type": "json_object"},
    "stop": null,
  });

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return json.decode(responseData['choices'][0]['message']['content']);
    } else {
      throw Exception('Failed to load data from llama');
    }
  } catch (e) {
    throw Exception('Failed to get data from llama.: $e');
  }
}
