// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously, use_super_parameters

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_lohin/group/Group.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class JoinGroupPage extends StatefulWidget {
  final String email;
  final Function refreshGroups;

  const JoinGroupPage({Key? key, required this.email, required this.refreshGroups}) : super(key: key);

  @override
  _JoinGroupPageState createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  TextEditingController groupNameController = TextEditingController();
  TextEditingController passwordGroupController = TextEditingController();
  String? message;
Future<void> joinGroup() async {
  var email = widget.email;
  var groupName = groupNameController.text;
  var groupPassword = passwordGroupController.text;

  if (groupName.isEmpty || groupPassword.isEmpty) {
    setState(() {
      message = 'กรุณากรอกข้อมูลให้ครบทุกช่อง';
    });
    return;
  }

  var url = Uri.parse('http://192.168.31.68:3000/join-group');
  var body = jsonEncode({
    'email': email,
    'passwordgroup': groupPassword,
  });
  var headers = {'Content-Type': 'application/json'};

  try {
    var response = await http.post(url, body: body, headers: headers);
    if (response.statusCode == 201) {
      var data = jsonDecode(response.body);
      if (data['success']) {
        Fluttertoast.showToast(msg: 'เข้าร่วมกลุ่มสำเร็จแล้ว');
        widget.refreshGroups(); 
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Group(
              email: email,
              groupName: groupName, passwordgroup: passwordGroupController.text,
               
            ),
          ),
        );
      } else {
        setState(() {
          message = data['message'] ?? 'ไม่สามารถเข้าร่วมกลุ่มได้';
        });
        Fluttertoast.showToast(msg: message ?? 'ไม่สามารถเข้าร่วมกลุ่มได้');
      }
    } else if (response.statusCode == 404) {
      setState(() {
        message = 'ไม่พบกลุ่มที่ต้องการ';
      });
      Fluttertoast.showToast(msg: 'ไม่พบกลุ่มที่ต้องการ');
    } else {
      setState(() {
        message = 'เกิดข้อผิดพลาดในการเข้าร่วมกลุ่ม';
      });
      Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาดในการเข้าร่วมกลุ่ม');
    }
  } catch (e) {
    setState(() {
      message = 'Error: $e';
    });
    Fluttertoast.showToast(msg: message!);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
            'assets/image/aula4.png',
              width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            )),
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.3),
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(0, 400, 0, 0),
            shrinkWrap: true,
            reverse: true,
            children: [
              Container(
                height: 600,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            Text(
                              'Join Group',
                              style: GoogleFonts.poppins(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: HexColor('#4f4f4f'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Form(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Group Name',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: HexColor('#8d8d8d'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: groupNameController,
                                decoration: InputDecoration(
                                  hintText: 'Enter group name',
                                  prefixIcon: const Icon(Icons.group),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the group name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Group Password',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: HexColor('#8d8d8d'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: passwordGroupController,
                                decoration: InputDecoration(
                                  hintText: 'Enter group password',
                                  prefixIcon: const Icon(Icons.lock),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the group password';
                                  }
                                  return null;
                                },
                                obscureText: false,
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: joinGroup,
                                  style: ElevatedButton.styleFrom(
                                  backgroundColor: HexColor('#40db90'),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  child: Center(
                                  child: Text(
                                    'Join Group',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (message != null)
                                Text(
                                  message!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
