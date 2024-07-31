// ignore_for_file: file_names, use_key_in_widget_constructors, use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_lohin/verify/VerificationScreen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lohin/Screen/Login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  
  TextEditingController realname = TextEditingController();
  TextEditingController surname = TextEditingController();
  TextEditingController birthday = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController studentId = TextEditingController();
  TextEditingController fieldOfStudy = TextEditingController();
  TextEditingController year = TextEditingController();
  TextEditingController sex = TextEditingController();

  bool agreement = false;

  Future<void> register() async {
    try {
      String uri = 'http://192.168.31.68:3000/register';
      var res = await http.post(
        Uri.parse(uri),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.text,
          'password': password.text,
          'agreement': agreement,
          'real_name': realname.text,
          'surname': surname.text,
          'birthday':birthday.text,
          'phone': phone.text,
          'student_id': studentId.text,
          'field_of_study': fieldOfStudy.text,
          'year': int.parse(year.text),
          'sex': sex.text,
        }),
      );
      var response = jsonDecode(res.body);
     if (response['success'] == true) {
  Fluttertoast.showToast(
    msg: 'ลงทะเบียนสำเร็จ กรุณาตรวจสอบอีเมลของคุณเพื่อยืนยัน',
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
  );

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => VerificationScreen(email: email.text)),
  );
} else {
  String errorMessage = response['message'] ?? 'ลงทะเบียนล้มเหลว';
  Fluttertoast.showToast(
    msg: errorMessage,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
  );
}

    } catch (e) {
      print('Error: $e');
      Fluttertoast.showToast(
        msg: 'เกิดข้อผิดพลาดในขณะนี้ กรุณาลองใหม่อีกครั้งในภายหลังค่ะ',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  Future<void> showAgreementPopup(BuildContext context) async {
    bool acceptedAgreement = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('เงื่อนไขและข้อตกลง'),
              content: const SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('โดยการคลิกที่ "ยืนยัน" แสดงว่าคุณยินยอม'),
                    SizedBox(height: 8),
                    Text('นโยบายโปรแกรมการละเมิดและการบังคับใช้นโยบายโปรแกรม...'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('ยืนยัน'),
                  onPressed: () {
                    setState(() {
                      acceptedAgreement = true;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      setState(() {
        agreement = acceptedAgreement;
      });
    });
  }

  Future<void> showAgreementRequiredPopup(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ข้อตกลงและเงื่อนไข'),
          content: const Text('กรุณายอมรับเงื่อนไขและข้อตกลงก่อนลงทะเบียน.'),
          actions: <Widget>[
            TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/image/aula4.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
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
                              icon: const Icon(Icons.arrow_back, color: Colors.black),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                );
                              },
                            ),
                            Text(
                              'Register',
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
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: HexColor('#8d8d8d'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: email,
                                decoration: InputDecoration(
                                  hintText: 'ex Lufy@ku.th',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'กรุณากรอกอีเมล์ของคุณ';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Password',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: HexColor('#8d8d8d'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: password,
                                decoration: InputDecoration(
                                  hintText: '**************',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'กรุณาใส่รหัสผ่านของคุณ';
                                  }
                                  return null;
                                },
                                obscureText: true,
                              ),
                             const SizedBox(height: 10),
                              Text(
                                'Confirm Password',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: HexColor('#8d8d8d'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: confirmPassword,
                                decoration: InputDecoration(
                                  hintText: '**************',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'กรุณายืนยันรหัสผ่านของคุณ';
                                  } else if (value != password.text) {
                                    return 'รหัสผ่านไม่ตรงกัน';
                                  }
                                  return null;
                                },
                                obscureText: true,
                              ),
                              const SizedBox(height: 10),
                               Text(
                                'Real Name',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: HexColor('#8d8d8d'),
                                ),
                              ),
                                TextFormField(
                                controller: realname,
                                decoration: InputDecoration(
                                  hintText: 'Your Real Name',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your real name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                               Text(
                                'Surname',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: HexColor('#8d8d8d'),
                                ),
                              ),
                                TextFormField(
                                controller: surname,
                                decoration: InputDecoration(
                                  hintText: 'Your Surname',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your surname';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                               Text(
                                'Birthday',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: HexColor('#8d8d8d'),
                                ),
                              ),
                                TextFormField(
                                controller: birthday,
                                decoration: InputDecoration(
                                  hintText: 'Your Birthday',
                                  prefixIcon: const Icon(Icons.cake),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your birthday';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 10),
                              Text(
                                'Phone',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: HexColor('#8d8d8d'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: phone,
                                decoration: InputDecoration(
                                  hintText: 'Your Phone Number',
                                  prefixIcon: const Icon(Icons.phone_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Student ID',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: HexColor('#8d8d8d'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: studentId,
                                decoration: InputDecoration(
                                  hintText: 'Your Student ID',
                                  prefixIcon: const Icon(Icons.school_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your student ID';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Field of Study',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: HexColor('#8d8d8d'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: fieldOfStudy,
                                decoration: InputDecoration(
                                  hintText: 'Your Field of Study',
                                  prefixIcon: const Icon(Icons.book_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your field of study';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Year',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: HexColor('#8d8d8d'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: year,
                                decoration: InputDecoration(
                                  hintText: 'Your Year of Study',
                                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your year of study';
                                  } else if (int.tryParse(value) == null) {
                                    return 'Please enter a valid year';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Sex',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: HexColor('#8d8d8d'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: sex,
                                decoration: InputDecoration(
                                  hintText: 'Your Gender',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your gender';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Checkbox(
                                    value: agreement,
                                    onChanged: (value) {
                                      if (value == true) {
                                        showAgreementPopup(context).then((_) {
                                          setState(() {
                                            agreement = value!;
                                          });
                                        });
                                      } else {
                                        setState(() {
                                          agreement = false;
                                        });
                                      }
                                    },
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      showAgreementPopup(context);
                                    },
                                    child: Text(
                                      'เงื่อนไขและข้อตกลง',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: HexColor('#44564a'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      if (agreement) {
                                        formKey.currentState!.save();
                                        await register();
                                      } else {
                                        showAgreementRequiredPopup(context);
                                      }
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
                                    'Register',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              ),
                              const SizedBox(height: 10),
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
