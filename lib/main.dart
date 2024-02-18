import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordle2Vec',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Word2VecExplorer(),
    );
  }
}

class Word2VecExplorer extends StatefulWidget {
  const Word2VecExplorer({super.key});

  @override
  State<Word2VecExplorer> createState() => _Word2VecExplorerState();
}

class _Word2VecExplorerState extends State<Word2VecExplorer> {
  final TextEditingController _firstWordController = TextEditingController();
  final TextEditingController _secondWordController = TextEditingController();
  String _similarityResult = '';
  String _differenceResult = '';
  String _secretWord = '';
  List<String> _hints = [];
  int _currentHintIndex = -1;

  // Define the base URL for your server
  final String _baseUrl = 'http://192.168.0.131:1237';

  @override
  void initState() {
    super.initState();
    _getRandomWord();
  }

  Future<void> _getRandomWord() async {
    var url = Uri.parse('$_baseUrl/random_word');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        _secretWord = json.decode(response.body)['random_word'];
        debugPrint(_secretWord);
        _hints.clear();
        _currentHintIndex = -1; // Reset to -1 to prepare for the first hint
        _getHintsForWord(_secretWord);
      });
    }
  }

  Future<void> _getHintsForWord(String word) async {
    var url = Uri.parse('$_baseUrl/hints'); // Ensure this is the correct endpoint
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({'word': word}),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final hints = responseBody['hints'] ?? [];
      debugPrint('Response body: $hints');
      setState(() {
        _hints = List<String>.from(hints);
        if (_hints.isNotEmpty) {
          _currentHintIndex = 0; // Automatically show the first hint
        }
      });
    } else {
      // Handle errors or unexpected status codes here
      debugPrint('Failed to load hints. Status code: ${response.statusCode}');
    }
  }


  // Function to calculate similarity
  Future<void> _calculateSimilarity() async {
    var url = Uri.parse('$_baseUrl/similarity');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'word1': _firstWordController.text,
        'word2': _secondWordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _similarityResult = "Similarity: ${data['similarity']}";
      });
    } else {
      // Handle error or show a message
      setState(() {
        _similarityResult = "Error calculating similarity";
      });
    }
  }

  // Function to calculate difference
  Future<void> _calculateDifferences() async {
    var url = Uri.parse('$_baseUrl/differences');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'word1': _firstWordController.text,
        'word2': _secondWordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _differenceResult = "Result: ${data['results']}";
      });
    } else {
      // Handle error or show a message
      setState(() {
        _differenceResult = "Error calculating difference";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word2Vec Explorer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side for hints
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  if (_hints.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...List.generate(
                          _currentHintIndex + 1,
                          (index) {
                            // Check if the current hint is the same as the secret word
                            bool isSecretWord = _hints[index] == _secretWord;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                _hints[index],
                                // Apply different style if it's the secret word
                                style: isSecretWord
                                    ? TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)
                                    : Theme.of(context).textTheme.titleMedium,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (_currentHintIndex < _hints.length - 1) {
                          _currentHintIndex++;
                        }
                      });
                    },
                    child: const Text('Show Next Hint'),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 32, thickness: 2, indent: 20, endIndent: 0, color: Colors.grey),
            // Right side for word similarity and differences
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _firstWordController,
                    decoration: const InputDecoration(
                      labelText: 'First Word',
                      border: OutlineInputBorder(),
                      hintText: 'Enter first word',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _secondWordController,
                    decoration: const InputDecoration(
                      labelText: 'Second Word',
                      border: OutlineInputBorder(),
                      hintText: 'Enter second word',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _calculateSimilarity,
                    child: const Text('Calculate Similarity'),
                  ),
                  if (_similarityResult.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(_similarityResult),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _calculateDifferences,
                    child: const Text('Calculate Differences'),
                  ),
                  if (_differenceResult.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(_differenceResult),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}