// ignore_for_file: file_names, library_private_types_in_public_api, avoid_print, use_super_parameters

import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart'; 

class GroupInfo extends StatefulWidget {
  final String passwordgroup;

  const GroupInfo({Key? key, required this.passwordgroup}) : super(key: key);

  @override
  _GroupInfoState createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  late Map<String, dynamic> groupData = {};
  

  @override
  void initState() {
    super.initState();
    fetchGroupData();
  }

  Future<void> fetchGroupData() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.31.68:3000/group-info?passwordgroup=${widget.passwordgroup}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          groupData = jsonDecode(response.body)['groupInfo'][0];
        });
      } else {
        print('Failed to load group data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _refreshGroupData() {
    fetchGroupData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Group Info',
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
            onPressed: _refreshGroupData,
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
                if (groupData.isNotEmpty) ...[
                  Text(
                    'ชื่อกลุ่ม: ${groupData['groupname']}',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 15, 14, 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'วิชา: ${groupData['subject']}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: const Color.fromARGB(255, 10, 10, 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'รหัสวิชา: ${groupData['subject_code']}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: const Color.fromARGB(255, 10, 10, 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ห้อง: ${groupData['room']}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: const Color.fromARGB(255, 10, 10, 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'เจ้าของกลุ่ม: ${groupData['owner_group']}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: const Color.fromARGB(255, 10, 10, 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'รหัสผ่านกลุ่ม: ${groupData['passwordgroup']}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: const Color.fromARGB(255, 10, 10, 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                ],
              ],
            
            ),
          ),
        ],
      ),
    );
  }
}
