// ignore_for_file: file_names, library_private_types_in_public_api, avoid_print, use_super_parameters

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_lohin/edit/editProfile.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart'; 

class ProfileScreen extends StatefulWidget {
  final String email;

  const ProfileScreen({Key? key, required this.email}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> userData = {};
  late String profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.31.68:3000/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body)['data'];
          profileImageUrl = userData['image_path'] ?? '';
        });
      } else {
        print('Failed to load user data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _refreshUserData() {
    fetchUserData(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 21, 20, 20),
          ),
        ),
        backgroundColor: Colors.green,
        actions: [
           IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshUserData,
            color: const Color.fromARGB(255, 17, 17, 17),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditScreen(email: widget.email)),
              );
            },
            color: const Color.fromARGB(255, 17, 17, 17),
          ),
         
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
          color: const Color.fromARGB(255, 14, 14, 14),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: const Color.fromARGB(255, 20, 20, 20),
                    backgroundImage: profileImageUrl.isNotEmpty ? Image.network('http://192.168.31.68:3000/$profileImageUrl').image : null,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Email: ${widget.email}',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 15, 14, 14),
                  ),
                ),
                const SizedBox(height: 20),
                if (userData.isNotEmpty) ...[
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(fontSize: 18, color: const Color.fromARGB(255, 10, 10, 10)),
                      children: [
                        const TextSpan(text: 'ชื่อจริง: '),
                        TextSpan(text: '${userData['real_name']}'),
                      ],
                    ),
                  ),
                  Text('นามสกุล: ${userData['surname']}',
                      style: GoogleFonts.poppins(fontSize: 18, color: const Color.fromARGB(255, 18, 18, 18))),
                  Text('วันเกิด: ${userData['birthday']}',
                      style: GoogleFonts.poppins(fontSize: 18, color: const Color.fromARGB(255, 18, 18, 18))),
                  Text('เบอร์: ${userData['phone']}',
                      style: GoogleFonts.poppins(fontSize: 18, color: const Color.fromARGB(255, 18, 18, 18))),
                  Text('รหัสนิสิต: ${userData['student_id']}',
                      style: GoogleFonts.poppins(fontSize: 18, color: const Color.fromARGB(255, 6, 6, 6))),
                  Text('สาขา: ${userData['field_of_study']}',
                      style: GoogleFonts.poppins(fontSize: 18, color: const Color.fromARGB(255, 7, 7, 7))),
                  Text('ชั้นปี: ${userData['year']}',
                      style: GoogleFonts.poppins(fontSize: 18, color: const Color.fromARGB(255, 13, 12, 12))),
                  Text('เพศ: ${userData['sex']}',
                      style: GoogleFonts.poppins(fontSize: 18, color: const Color.fromARGB(255, 9, 9, 9))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
