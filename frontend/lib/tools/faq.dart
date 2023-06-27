import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/tools/chat-bot/chatscreen.dart';
import 'package:http/http.dart' as http;

class Question {
  final String category;
  final String question;
  final String answer;

  Question({required this.category, required this.question, required this.answer});
}

class FAQPage extends StatefulWidget {

  final String? initialQuery;

  const FAQPage({Key? key, this.initialQuery}) : super(key: key);

  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  Future<void> fetchFAQs() async {
    final response = await http.get(Uri.parse('http://itssecurepath.ddns.net:8000/faq/'));
    String myString = ''; // Declare myString outside the if statement
    if (response.statusCode == 200) {
      // Successful response
      if (response.body.startsWith('"') && response.body.endsWith('"')) {
         myString = response.body.substring(1, response.body.length - 1);
         String charToRemove = "\\";
         myString = myString.replaceAll(charToRemove, "");
         print(myString);
      }
      final faqsJson = jsonDecode(myString); // Type declaration

      List<Question> fetchedQuestions = [];

      for (var faq in faqsJson) {
        print(faq);
        Question question = Question(
            category: faq['title'] as String,
            question: faq['title'] as String,
            answer: faq['content'] as String,
        );
        fetchedQuestions.add(question);
      }

      setState(() {
        _allQuestions = fetchedQuestions;
      });
    } else {
      // Error handling
      print('Failed to fetch FAQs: ${response.statusCode}');
    }
  }



  List<Question> _allQuestions = [];


  List<Question> _searchResults = [];

  final TextEditingController _searchController = TextEditingController();



  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchController.text = widget.initialQuery ?? '';

    fetchFAQs();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void searchFAQs(String query) async {
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('http://itssecurepath.ddns.net:8000/faq/search'));
    request.body = json.encode([query]);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      final faqsJson = jsonDecode(responseBody);

      List<Question> searchResults = [];

      for (var faq in faqsJson) {
        Question question = Question(
          category: faq['title'] as String,
          question: faq['title'] as String,
          answer: faq['content'] as String,
        );
        searchResults.add(question);
      }

      setState(() {
        _searchResults = searchResults;
      });
    } else {
      print('Failed to search FAQs: ${response.reasonPhrase}');
    }
  }

  void _onSearchChanged() {
    String searchText = _searchController.text.trim().toLowerCase();
    if (searchText.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    searchFAQs(searchText);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
        Column(

          children: [
              SizedBox(
                height: 30.0,
              ),
          Text(
            'FAQ',
            style: TextStyle(
              fontSize: 35.0,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 16.0),
          // Add your FAQ content here
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search FAQ',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(

            child: ListView.builder(
              itemCount: _searchResults.isEmpty
                  ? _allQuestions.length
                  : _searchResults.length,
              itemBuilder: (context, index) {
                Question? question = _searchResults.isEmpty
                    ? (_allQuestions.length > index ? _allQuestions[index] : null)
                    : (_searchResults.length > index ? _searchResults[index] : null);

                if (_searchResults.isNotEmpty) {
                  if ((index == 0 && _searchResults.isNotEmpty) || question?.category != _searchResults[index].category) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            question!.category,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildQuestionTile(question!),
                      ],
                    );
                  }
                }

                return _buildQuestionTile(question!);
              },
            ),
          ),
      ]
      ),
    );
  }

  Widget _buildQuestionTile(Question question) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(question.question),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(question.answer),
          ),
        ],
      ),
    );
  }
}