// ignore_for_file: use_super_parameters, library_private_types_in_public_api, use_key_in_widget_constructors, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class HomeworkScreen extends StatefulWidget {
  final String assignment;
  final String email;
  final String passwordgroup;

  const HomeworkScreen({Key? key, required this.email, required this.assignment, required this.passwordgroup}) : super(key: key);

  @override
  _HomeworkScreenState createState() => _HomeworkScreenState();
}

class PdfScreen extends StatelessWidget {
  final File file;

  const PdfScreen({required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Viewer')),
      body: PDFView(
        filePath: file.path,
      ),
    );
  }
}

class ImageScreen extends StatelessWidget {
  final String imageUrl;

  const ImageScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Viewer'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  List<Map<String, dynamic>> homework = [];
  int maxScore = 0;  
  final TextEditingController maxScoreController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _fetchHomework();
    _fetchMaxScore();
  }


  Future<void> _fetchHomework() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.31.68:3000/get-homework/${widget.assignment}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('API Response: $data');  
        setState(() {
          homework = List<Map<String, dynamic>>.from(data['homework']);
        });
      } else if (response.statusCode == 404) {
        setState(() {
          homework = [];
        });
      } else {
        throw Exception('Failed to load homework data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _showPdf(BuildContext context, String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final file = File('${Directory.systemTemp.path}/temp.pdf');
        await file.writeAsBytes(response.bodyBytes);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfScreen(file: file),
          ),
        );
      } else {
        throw Exception('Failed to load PDF');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _submitScore(String emailMember, String passwordgroup, int score, String idAssignment) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.31.68:3000/update-score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email_member': emailMember,
          'passwordgroup': passwordgroup,
          'score': score,
          'id_assignment': idAssignment,
        }),
      );

      if (response.statusCode == 200) {
        print('Score updated successfully');
      } else {
        print('Failed to update score: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _updateMaxScore(int newMaxScore) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.31.68:3000/update-max-score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_assignment': widget.assignment,
          'maxScore': newMaxScore,
        }),
      );

      if (response.statusCode == 200) {
        print('Max score updated successfully');
      } else {
        print('Failed to update max score: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _setMaxScore() async {
    int? newMaxScore = int.tryParse(maxScoreController.text);
    if (newMaxScore != null && newMaxScore > 0) {
      setState(() {
        maxScore = newMaxScore;
        maxScoreController.clear();
      });
      await _updateMaxScore(newMaxScore);
    } else {
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number greater than 0')),
      );
    }
  }

  Future<void> _fetchMaxScore() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.31.68:3000/get-max-score/${widget.assignment}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          maxScore = data['maxScore'];
        });
      } else if (response.statusCode == 404) {
        print('Assignment not found');
      } else {
        print('Failed to fetch max score');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  String _formatDate(String date) {
    try {
      final DateTime dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework'),
        backgroundColor: Colors.green,
      ),
      body: homework.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No homework found for this assignment',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Maximum Score: $maxScore',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: maxScoreController,
                              decoration: const InputDecoration(
                                labelText: 'Set Maximum Score',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _setMaxScore,
                            child: const Text('Set Score'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: homework.length,
                    itemBuilder: (context, index) {
                      final hw = homework[index];
                      final TextEditingController scoreController = TextEditingController();

                      final String emailMember = hw['email_member'] ?? 'Unknown';
                      final String passwordgroup = hw['passwordgroup'] ?? 'Unknown';



                     return Card(
                        margin: const EdgeInsets.all(10),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Submitted by: $emailMember',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              
                              const SizedBox(height: 5),
                              Text(
                                'Message: ${hw['message'] ?? 'No message'}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Submission Date: ${_formatDate(hw['submission_date'] ?? '')}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 5),
                              ...List<Widget>.from(hw['files']?.map<Widget>((file) {
                                String filename = file['filename'] ?? 'Unknown file';
                                String extension = filename.split('.').last.toLowerCase();
                                String url = 'http://192.168.31.68:3000/uploads/$filename';

                                if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
                                  return GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ImageScreen(imageUrl: url),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                      child: Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                } else if (extension == 'pdf') {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: TextButton(
                                      onPressed: () => _showPdf(context, url),
                                      child: Text(
                                        filename,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      'File: $filename',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                }
                              }) ?? []),
                              const SizedBox(height: 10),
                              TextField(
                                controller: scoreController,
                                decoration: const InputDecoration(
                                  labelText: 'Enter Score',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              onChanged: (value) {
                                  int? score = int.tryParse(value);
                                  if (score != null && score > maxScore) {
                                    scoreController.text = maxScore.toString();
                                    scoreController.selection = TextSelection.collapsed(offset: scoreController.text.length);
                                  }
                                },
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  int? score = int.tryParse(scoreController.text);
                                  if (score != null && score >= 0 && score <= maxScore) {
                                    _submitScore(emailMember, passwordgroup, score, widget.assignment);
                                  } else {
                                   
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Please enter a valid score between 0 and $maxScore')),
                                    );
                                  }
                                },
                                child: const Text('Submit Score'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
