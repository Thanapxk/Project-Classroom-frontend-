// ignore_for_file: file_names, use_super_parameters, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_lohin/Screen/HomeScreen.dart';


import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class CreateGroup extends StatefulWidget {
  final String email;
  final Function refreshGroups;

  const CreateGroup({Key? key, required this.email, required this.refreshGroups}) : super(key: key);

  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController groupNameController;
  late TextEditingController subjectController;
  late TextEditingController subjectCodeController;
  late TextEditingController roomController;
  String? message; 

  @override
  void initState() {
    super.initState();
    groupNameController = TextEditingController();
    subjectController = TextEditingController();
    subjectCodeController = TextEditingController();
    roomController = TextEditingController();
  }

  @override
  void dispose() {
    groupNameController.dispose();
    subjectController.dispose();
    subjectCodeController.dispose();
    roomController.dispose();
    super.dispose();
  }

  Future<void> createGroup() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.31.68:3000/create-group'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'groupname': groupNameController.text,
          'subject': subjectController.text,
          'subject_code': subjectCodeController.text,
          'room': roomController.text,
          'owner_email': widget.email,
        }),
      );

      var responseJson = jsonDecode(response.body);

      if (response.statusCode == 201 && responseJson['success'] == true) {
        Fluttertoast.showToast(msg: 'สร้างกลุ่มสำเร็จ');
        widget.refreshGroups(); 
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                
                email: widget.email
              )),
          (Route<dynamic> route) => false,
        );
      } else {
        setState(() {
          message = 'Group already exists. Please check your details.';
        });
        Fluttertoast.showToast(msg: 'ชื่อกลุ่มซ้ำ');
      }
    } catch (e) {
      setState(() {
        message = 'Error: $e';
      });
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child:  Image.asset(
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
                    child: Form(
                      key: formKey,
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
                                'Create Group',
                                style: GoogleFonts.poppins(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: HexColor('#4f4f4f'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          buildTextField('Group Name', groupNameController, Icons.group),
                          buildTextField('Subject', subjectController, Icons.book),
                          buildTextField('Subject Code', subjectCodeController, Icons.code),
                          buildTextField('Room', roomController, Icons.room),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  createGroup();
                                }
                              },
                             style: ElevatedButton.styleFrom(
                                  backgroundColor: HexColor('#40db90'),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              child: Center(
                                  child: Text(
                                    'Create Group',
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
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: HexColor('#8d8d8d'),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the $label';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
      ],
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
