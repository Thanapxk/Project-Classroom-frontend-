// ignore_for_file: file_names, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lohin/group/Assign.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';


class Classwork extends StatefulWidget {
  final String passwordgroup;
  final String email;
  
  const Classwork({super.key, required this.passwordgroup, required this.email});

  @override
  State<Classwork> createState() => _ClassworkState();
}

class _ClassworkState extends State<Classwork> {
  List<dynamic> assignments = [];
  Map<int, Map<String, dynamic>> homeworkData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<List<dynamic>> fetchAssignments(String passwordgroup) async {
    final uri = Uri.parse(
        'http://192.168.31.68:3000/get-assignments?passwordgroup=$passwordgroup');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final assignments = json.decode(response.body)['assignments'];
      return assignments;
    } else {
      throw Exception('Failed to fetch assignments');
    }
  }

 Future<Map<String, dynamic>> fetchHomeworkData(String email, int assignmentId) async {
    final uri = Uri.parse(
        'http://192.168.31.68:3000/get-homework?email=$email&id_assignment=$assignmentId');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final homeworkData = json.decode(response.body);
      return homeworkData;
    } else {
      throw Exception('Failed to fetch homework data');
    }
  }
Future<void> _loadAssignments() async {
    try {
      final fetchedAssignments = await fetchAssignments(widget.passwordgroup);
      setState(() {
        assignments = fetchedAssignments;
        isLoading = false;
      });

     
      for (var assignment in assignments) {
        final assignmentId = assignment['id'];
        final homework = await fetchHomeworkData(widget.email, assignmentId);
        setState(() {
          homeworkData[assignmentId] = homework; 
        });
      }
    } catch (e) {
      print('Error fetching assignments: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Future<File> loadPdfFromUrl(String url, String filename) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');

      if (await file.exists()) {
        return file;
      } else {
        final response = await Dio().get(
          url,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            },
          ),
        );
        final raf = file.openSync(mode: FileMode.write);
        raf.writeFromSync(response.data);
        await raf.close();
        return file;
      }
    } catch (e) {
      throw Exception("Error downloading PDF: $e");
    }
  }

  void _showPdfDialog(BuildContext context, File file) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.7,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: PDFView(
                    filePath: file.path,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : assignments.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No assignments available',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadAssignments,
                child: ListView.builder(
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = assignments[index];
                    return GestureDetector(
                      onTap: () {
       Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssignmentDetailScreen(
                          assignment: assignment,
                          email: widget.email,
                          homeworkData: const {}, 
                        ),
                      ),
                    );


                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  assignment['title'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'ครบกำหนด: ${assignment['due_date'] != null ? _formatDate(assignment['due_date']) : 'ไม่มีกำหนด'}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  ' ${assignment['description']}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 10),
                                if (assignment['files'] != null &&
                                    assignment['files'].isNotEmpty)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      
                                      const SizedBox(height: 10),
                                      ...assignment['files'].map<Widget>((file) {
                                        String filename = file['filename'];
                                        String extension = filename
                                            .split('.')
                                            .last
                                            .toLowerCase();
                                        List<String> imageExtensions = [
                                          'jpg',
                                          'png',
                                          'gif',
                                          'jpeg'
                                        ];

                                        if (imageExtensions.contains(extension)) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Center(
                                              child: Image.network(
                                                'http://192.168.31.68:3000/uploads/$filename',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          );
                                        } else {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: GestureDetector(
                                              onTap: () async {
                                                final file = await loadPdfFromUrl(
                                                    'http://192.168.31.68:3000/uploads/$filename',
                                                    filename);
                                                _showPdfDialog(context, file);
                                              },
                                              child: Text(filename),
                                            ),
                                          );
                                        }
                                      }).toList()
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
  }
}
