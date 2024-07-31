// ignore_for_file: file_names, use_key_in_widget_constructors, use_build_context_synchronously, avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lohin/Screen/Login.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final formKey = GlobalKey<FormState>();
  final List<TextEditingController> controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  late Timer _timer;
  int _start = 30;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            Fluttertoast.showToast(
              msg: 'รหัสยืนยันหมดอายุ กรุณาขอรหัสใหม่',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
            );
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Future<void> verifyCode() async {
    if (_start == 0) {
      Fluttertoast.showToast(
        msg: 'รหัสยืนยันหมดอายุ กรุณาขอรหัสใหม่',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }
    try {
       String verificationCode = controllers.map((controller) => controller.text).join();
      String uri = 'http://192.168.31.68:3000/check-verification-code';
      var res = await http.post(
        Uri.parse(uri),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'verificationCode': verificationCode,
        }),
      );
      var response = jsonDecode(res.body);
      if (response['success'] == true) {
        Fluttertoast.showToast(
          msg: 'ยืนยันอีเมลสำเร็จแล้ว',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        String errorMessage = response['message'] ?? 'ยืนยันรหัสล้มเหลว';
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

  Future<void> requestVerificationCode() async {
    try {
      String uri = 'http://192.168.31.68:3000/request-verification-code';
      var res = await http.post(
        Uri.parse(uri),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      );
      var response = jsonDecode(res.body);
      if (response['success'] == true) {
        Fluttertoast.showToast(
          msg: 'ร้องขอรหัสยืนยันใหม่แล้ว',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        setState(() {
          _start = 30;  // reset timer
          startTimer();
        });
      } else {
        String errorMessage = response['message'] ?? 'ไม่สามารถร้องขอรหัสยืนยันใหม่ได้';
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

  Future<void> requestVerificationLink() async {
    try {
      String uri = 'http://192.168.31.68:3000/resend-verification-link';
      var res = await http.post(
        Uri.parse(uri),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      );
      var response = jsonDecode(res.body);
      if (response['success'] == true) {
        Fluttertoast.showToast(
          msg: 'ลิงก์ยืนยันใหม่ถูกส่งไปแล้ว',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      } else {
        String errorMessage = response['message'] ?? 'ไม่สามารถส่งลิงก์ยืนยันใหม่ได้';
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


  void moveFocus(int index) {
    if (index < focusNodes.length - 1) {
      focusNodes[index + 1].requestFocus();
    } else {
      focusNodes[index].unfocus();
    }
  }


    @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Image.network(
            'https://www.nippon.com/en/ncommon/contents/japan-data/2527115/2527115.jpg',
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
            padding: const EdgeInsets.fromLTRB(0, 300, 0, 0),
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
                    padding: const EdgeInsets.fromLTRB(30, 50, 30, 50),
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
                              'Verify Email',
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
                                '  O          T          P        👑',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: HexColor('#8d8d8d'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(6, (index) {
                                  return SizedBox(
                                    width: 40,
                                    child: TextFormField(
                                      controller: controllers[index],
                                      focusNode: focusNodes[index],
                                      maxLength: 1,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 24),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          moveFocus(index);
                                        }
                                      },
                                      decoration: const InputDecoration(
                                        counterText: '',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 20),
                              Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    const SizedBox(height: 20),
    Align(
      alignment: Alignment.center,
      child: Text(
        'หมดเวลาใน $_start วินาที',
        style: GoogleFonts.poppins(
        fontSize: 14,
         color: _start > 0 ? Colors.green : Colors.red,
         
        ),
      ),
    ),
    
  ],
),

                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: verifyCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: HexColor('#40db74'),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Center(
                                  child: Text(
                                    'Verify',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
    Align(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: _start == 0 ? requestVerificationCode : null,
        child: Text(
          'ขอรหัสยืนยันใหม่',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: _start == 0 ? Colors.green : Colors.grey,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ),
                        const SizedBox(height: 3),
                        Center(
                          child: TextButton(
                            onPressed: requestVerificationLink,
                            child: Text(
                              'ขอ Link สำหรับ Verify',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
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