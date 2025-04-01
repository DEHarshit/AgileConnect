import 'dart:convert';
import 'package:http/http.dart' as http;

class SummarizationService {
  static const String apiUrl = "https://api.meaningcloud.com/summarization-1.0";

  static Future<String> summarizeText(String text) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "txt": text,
          "sentences": "3",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('summary')) {
          return data['summary'];
        } else {
          return "Failed to generate summary.";
        }
      } else {
        print("API Error: ${response.body}");
        return "Failed to generate summary. (Status code: ${response.statusCode})";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
