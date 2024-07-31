// ignore_for_file: file_names, use_super_parameters, library_private_types_in_public_api, avoid_print, unused_element

import 'package:flutter/material.dart';
import 'package:flutter_lohin/point/work.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';


class Checkwork extends StatefulWidget {
  final String passwordgroup;
  final String email;
  const Checkwork({Key? key, required this.passwordgroup, required this.email}) : super(key: key);

  @override
  _CheckworkState createState() => _CheckworkState();
}

class _CheckworkState extends State<Checkwork> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> assignments = [];

  @override
  void initState() {
    super.initState();
    _fetchAssignments();
  }

  Future<void> _fetchAssignments() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.31.68:3000/get-assignments?passwordgroup=${widget.passwordgroup}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          assignments = List<Map<String, dynamic>>.from(data['assignments']);
        });
      } else if (response.statusCode == 404) {
        setState(() {
          assignments = [];
        });
      } else {
        throw Exception('Failed to load assignments data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }



String _formatDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Check Work',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.white,
      body: assignments.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'You don\'t have any assignments',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                return Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeworkScreen(email: widget.email,
                                  assignment: assignment['id'].toString(),
                                  passwordgroup:widget.passwordgroup)),
              );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.green.shade200,
                                width: 2,
                              ),
                              color: Colors.green.shade50,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Work: ${assignment['title']}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                              
                                Text(
                                  'ครบกำหนด: ${assignment['due_date'] != null ? _formatDate(assignment['due_date']) : 'ไม่มีกำหนด'}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                
                              ],
                            ),
                          ),
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
