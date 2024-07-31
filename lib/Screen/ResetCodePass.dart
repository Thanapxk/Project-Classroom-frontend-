// ignore_for_file: file_names, use_super_parameters, avoid_function_literals_in_foreach_calls, use_build_context_synchronously, avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lohin/Screen/Login.dart';
import 'package:flutter_lohin/Screen/ResetPassword.dart';

class ResetCodePass extends StatefulWidget {
  final String email;
  const ResetCodePass({Key? key, required this.email}) : super(key: key);

  @override
  State<ResetCodePass> createState() => _ResetCodePassState();
}

class _ResetCodePassState extends State<ResetCodePass> {
  final formKey = GlobalKey<FormState>();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  final List<TextEditingController> controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
 
  Timer? _timer;
  int _remainingTime = 60;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    newPasswordController.dispose();
    
    confirmPassword.dispose();
    controllers.forEach((controller) => controller.dispose());
    focusNodes.forEach((node) => node.dispose());
    super.dispose();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        Fluttertoast.showToast(
          msg: '',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
    });
  }
   void resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingTime =60;
    });
    startTimer();
  }

   Future<void> resetPassword() async {
    if (_remainingTime <= 0) {
      Fluttertoast.showToast(
        msg: 'รหัสรีเซ็ตรหัสผ่านหมดอายุแล้ว กรุณาร้องขอรหัสใหม่',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }
    
    try {
      String verificationCode =
          controllers.map((controller) => controller.text).join();
      String uri = 'http://192.168.31.68:3000/reset-password';
      var res = await http.post(
        Uri.parse(uri),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'resetCode':  verificationCode,
          'newPassword': newPasswordController.text,
        }),
      );
      var response = jsonDecode(res.body);
      if (response['success'] == true) {
        Fluttertoast.showToast(
          msg: 'รีเซ็ตรหัสผ่านสำเร็จ',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      } else {
        String errorMessage = response['message'] ?? 'ไม่สามารถรีเซ็ตรหัสผ่านได้';
        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
    } catch (e) {
      print('Error: $e');
      Fluttertoast.showToast(
        msg: 'เกิดข้อผิดพลาดในการรีเซ็ตรหัสผ่าน',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  Future<void> requestPasswordCode() async {
    try {
      String uri = 'http://192.168.31.68:3000/request-passwordcode';
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
        resetTimer(); 
        
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
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 400),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textDirection: TextDirection.ltr,
                      verticalDirection: VerticalDirection.down,
                      children: [
                        Text(
                          'Reset Password',
                          style: GoogleFonts.poppins(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: HexColor('#4f4f4f'),
                          ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                              Text(
                                'New Password',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: HexColor('#8d8d8d'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: newPasswordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: '**************',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'กรุณากรอกรหัสของคุณ';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.text,
                              ),
                              const SizedBox(height: 20),
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
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: '**************',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'กรุณากรอกรหัสของคุณ';
                                  }
                                  if (value != newPasswordController.text) {
                                    return 'รหัสผ่านไม่ตรงกัน';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.text,
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: Text(
                                  'รหัสยืนยันจะหมดอายุใน $_remainingTime วินาที',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: _remainingTime > 0 ? Colors.green : Colors.red,
                                  ),
                                ),
                              ),
    
  
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: resetPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: HexColor('#40db90'),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Reset Password',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              Center(
                                child: GestureDetector(
                                  onTap: requestPasswordCode,
                                  child: Text(
                                    'ขอรหัสยืนยันใหม่',
                                    style: GoogleFonts.poppins(
            fontSize: 16,
            color: _remainingTime == 0 ? Colors.green : Colors.grey,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                             
                              
                              Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ResetPasswordPage(),
          ),
        );
      },
      child: Text(
        ' Back',
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: HexColor('#44564a'),
        ),
      ),
    ),
  ],
),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
