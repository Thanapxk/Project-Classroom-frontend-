// ignore_for_file: file_names, depend_on_referenced_packages,, use_super_parameters, library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class EditScreen extends StatefulWidget {
  final String email;

  const EditScreen({Key? key, required this.email}) : super(key: key);

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController realnameController;
  late TextEditingController surnameController;
  late TextEditingController birthdayController;
  late TextEditingController phoneController;
  late TextEditingController studentIdController;
  late TextEditingController fieldOfStudyController;
  late TextEditingController yearController;
  late TextEditingController sexController;
  File? _image;
  String? imagePath;

  @override
  void initState() {
    super.initState();
    realnameController = TextEditingController();
    surnameController = TextEditingController();
    birthdayController = TextEditingController();
    phoneController = TextEditingController();
    studentIdController = TextEditingController();
    fieldOfStudyController = TextEditingController();
    yearController = TextEditingController();
    sexController = TextEditingController();
    
    fetchUserData();
    
  }

  @override
  void dispose() {
    realnameController.dispose();
    surnameController.dispose();
    birthdayController.dispose();
    phoneController.dispose();
    studentIdController.dispose();
    fieldOfStudyController.dispose();
    yearController.dispose();
    sexController.dispose();
    super.dispose();
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.31.68:3000/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          realnameController.text = data['real_name'] ?? '';
          surnameController.text = data['surname'] ?? '';
          birthdayController.text = data['birthday'] ?? '';
          phoneController.text = data['phone'] ?? '';
          studentIdController.text = data['student_id'] ?? '';
          fieldOfStudyController.text = data['field_of_study'] ?? '';
          yearController.text = data['year']?.toString() ?? '';
          sexController.text = data['sex'] ?? '';
          imagePath = data['image_url'] ?? ''; 
        });
      } else {
        print('Error fetching user data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> updateProfile() async {
    try {
      final uri = Uri.parse('http://192.168.31.68:3000/edit-profile');
      final request = http.MultipartRequest('PUT', uri)
        ..fields['email'] = widget.email
        ..fields['realname'] = realnameController.text.trim()
        ..fields['surname'] = surnameController.text.trim()
        ..fields['birthday'] = birthdayController.text.trim()
        ..fields['phone'] = phoneController.text.trim()
        ..fields['studentId'] = studentIdController.text.trim()
        ..fields['fieldOfStudy'] = fieldOfStudyController.text.trim()
        ..fields['year'] = yearController.text.trim()
        ..fields['sex'] = sexController.text.trim();

      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profileImage',
          _image!.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('Profile updated successfully');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('บันทึกข้อมูลสำเร็จ'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('เสร็จสิ้น'),
                ),
              ],
            );
          },
        );
      } else {
        print('Error updating profile');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('เพิ่มข้อมูลไม่สำเร็จ'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('ตกลง'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
             fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 21, 20, 20),
          ),
        ),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: updateProfile,
            color: Colors.black,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (imagePath != null && imagePath!.isNotEmpty) 
                Image.network(
                  'http://192.168.31.68:3000/uploads/$imagePath',
                  height: 150,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Could not load image');
                  },
                ),

              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image),
                    SizedBox(width: 10),
                    Text('เลือกรูปภาพโปรไฟล์'),
                  ],
                ),
              ),
              if (_image != null) ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 30, color: Colors.blue),
                        SizedBox(width: 10),
                        Text(
                          'เลือกรูปภาพอื่น',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Image.file(
                  _image!,
                  height: 200,
                ),
              ],
              const SizedBox(height: 12),
              buildTextField('Real Name', realnameController, Colors.blue),
              const SizedBox(height: 12),
              buildTextField('Surname', surnameController, const Color.fromARGB(255, 8, 52, 153)),
              const SizedBox(height: 12),
              buildTextField('Birthday', birthdayController, const Color.fromARGB(255, 74, 25, 234)),
              const SizedBox(height: 12),
              buildTextField('Phone', phoneController, Colors.red),
              const SizedBox(height: 12),
              buildTextField('Student ID', studentIdController, Colors.orange),
              const SizedBox(height: 12),
              buildTextField('Field of Study', fieldOfStudyController, Colors.brown),
              const SizedBox(height: 12),
              buildTextField('Year', yearController, Colors.grey, isNumber: true),
              const SizedBox(height: 12),
              buildTextField('Sex', sexController, Colors.pink),
              const SizedBox(height: 20),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, TextEditingController controller, Color color, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: color),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color),
        ),
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
