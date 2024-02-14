import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'point_projection.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, List<double>> examplePoints = {
      "Hello": [1.0, 2.0, 3.0],
      "World": [-1.0, -2.0, -3.0],
      "Flutter": [2.0, -1.0, 1.0],
      "Dart": [-2.0, 1.0, -1.0]
    };
    return MaterialApp(
      title: '3D Points Visualization',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: ThreeDPointsProjection(points: examplePoints,), // Instantiate your ThreeDPointsProjection widget here
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

  // Define the base URL for your server
  final String _baseUrl = 'http://192.168.0.131:1237';

  // Function to calculate similarity
  Future<void> _calculateSimilarity() async {
    var url = Uri.parse('$_baseUrl/similarity');
    debugPrint('Request URL: $url');
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
Future<void> _calculateDifference() async {
  var url = Uri.parse('$_baseUrl/difference'); // Ensure this matches your Flask endpoint
  debugPrint('Request URL: $url');
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
      _differenceResult = "Difference: ${data['difference']} (Score: ${data['score']})";
    });
  } else {
    // Handle error or show a message
    setState(() {
      _differenceResult = "Error calculating difference";
    });
  }
}
Future<void> _calculateDifferences() async {
  var url = Uri.parse('$_baseUrl/differences'); // Ensure this matches your Flask endpoint
  debugPrint('Request URL: $url');
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
        child: Column(
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
    );
  }
}