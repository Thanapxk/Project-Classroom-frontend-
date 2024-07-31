// ignore_for_file: file_names, library_private_types_in_public_api, prefer_final_fields, unused_element, avoid_print, use_build_context_synchronously

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lohin/edit/editProfile.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';


class AssignmentDetailScreen extends StatefulWidget {
  final dynamic assignment;
  final String email;
  final Map<String, dynamic> homeworkData;

  const AssignmentDetailScreen({super.key, required this.assignment, required this.email,required this.homeworkData,});

  @override
  _AssignmentDetailScreenState createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<File> _files = [];
  List<String> _uploadedFiles = [];
  
  bool _isSubmitted = false;
bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    
     _checkSubmission();
  }

Future<void> _delayedLoading() async {
  await Future.delayed(const Duration(milliseconds: 3000000));
  _checkSubmission();
}

Future<void> _checkSubmission() async {
    try {
      final response = await Dio().get(
        'http://192.168.31.68:3000/check-submission',
        queryParameters: {
          'id_assignment': widget.assignment['id'],
          'email_member': widget.email,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          _isSubmitted = true;
          _uploadedFiles = List<String>.from(data['files']);
        });
      } else {
        setState(() {
          _isSubmitted = false;
          _uploadedFiles.clear();
        });
      }
    } catch (e) {
      print('Error checking submission: $e');
    } finally {
      setState(() {
        _isLoading = false; 
      });
    }
  }


   Future<void> _unsubmitFiles() async {
    if (!_isSubmitted) return; 
    setState(() {
      _uploadedFiles.clear();
      _files.clear();
      _isSubmitted = false;
    });

    try {
      final response = await Dio().delete(
        'http://192.168.31.68:3000/unsubmit',
        data: {
          'id_assignment': widget.assignment['id'],
          'email_member': widget.email,
        },
      );

      if (response.statusCode == 200) {
        print('Unsubmission successful');
      } else {
        print('Failed to unsubmit');
      }
    } catch (e) {
      print('Error unsubmitting files: $e');
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

  Future<void> _pickFiles() async {
    if (_isSubmitted) return; 

    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
      setState(() {
        _files.addAll(files);
      });
    }
  }


  Future<void> _uploadFiles() async {
    if (_isSubmitted) return; 

    String uploadUrl = 'http://192.168.31.68:3000/upload';
    Dio dio = Dio();

    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('email', widget.email));
      formData.fields.add(MapEntry('assignmentId', widget.assignment['id'].toString()));
      formData.fields.add(MapEntry('message', _messageController.text));

      for (File file in _files) {
        formData.files.add(MapEntry(
          'files',
          await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        ));
      }

      var response = await dio.post(uploadUrl, data: formData);

     if (response.statusCode == 200) {
        setState(() {
          _uploadedFiles = _files.map((file) => file.path.split('/').last).toList();
          _files.clear();
          _messageController.clear();
          _isSubmitted = true;
        });
        print('Files uploaded successfully');
      } else {
        print('Failed to upload files');
      }
    } catch (e) {
      print('Error uploading files: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Assignment Details',
          style: GoogleFonts.poppins(
            fontSize: 25,
            color: const Color.fromARGB(255, 21, 20, 20),
          ),
        ),
      ),
      body:_isLoading 
        ? const Center(
            child: CircularProgressIndicator(),
          )
       :SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.assignment['title'] ?? 'No Title',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
  widget.assignment['due_date'] != null 
    ? 'ครบกำหนด:${_formatDate(widget.assignment['due_date'])} ' 
    : 'No due date (Not Set)',
  style: GoogleFonts.poppins(
    fontSize: 16,
  ),
),

            const SizedBox(height: 10),
            Text(
              widget.assignment['description'] ?? 'No Description',
              style: GoogleFonts.poppins(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            if (widget.assignment['files'] != null && widget.assignment['files'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  
                  const SizedBox(height: 10),
                  ...widget.assignment['files'].map<Widget>((file) {
                    String filename = file['filename'];
                    String extension = filename.split('.').last.toLowerCase();
                    List<String> imageExtensions = ['jpg', 'png', 'gif', 'jpeg'];

                    if (imageExtensions.contains(extension)) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Center(
                          child: Image.network(
                            'http://192.168.31.68:3000/uploads/$filename',
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    } else if (extension == 'pdf') {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Center(
                          child: TextButton(
                            onPressed: () async {
                              File file = await loadPdfFromUrl(
                                'http://192.168.31.68:3000/uploads/$filename',
                                filename,
                              );
                              _showPdfDialog(context, file);
                            },
                            child: Text(
                              filename,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }).toList(),
                ],
              ),
            const SizedBox(height: 20),
            if (!_isSubmitted) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
               ElevatedButton.icon(
  onPressed: _pickFiles,
  icon: const Icon(
    Icons.attach_file,
    size: 25, 
  ),
  label: const SizedBox.shrink(),
  style: ElevatedButton.styleFrom(
    foregroundColor: Colors.white, 
    backgroundColor: Colors.green,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.all(4),
    minimumSize: const Size(30, 60), 
  ),
),


                ],
              ),
              const SizedBox(height: 10),
              if (_files.isNotEmpty) ...[
                const Text(
                  'Selected Files:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: _files.map((file) {
    String filename = file.path.split('/').last;
    String extension = filename.split('.').last.toLowerCase();
    List<String> imageExtensions = ['jpg', 'png', 'gif', 'jpeg'];

    if (imageExtensions.contains(extension)) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Center(
          child: Image.file(
            file,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (extension == 'pdf') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: TextButton(
          onPressed: () async {
            
            File pdfFile = await loadPdfFromUrl(
              'http://192.168.31.68:3000/uploads/$filename',
              filename,
            );
            _showPdfDialog(context, pdfFile);
          },
          child: Text(
            filename,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.blue,
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }).toList(),
),

              ],
              const SizedBox(height: 10),
              
              SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _uploadFiles,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: HexColor('#40db90'),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                ),
                                child: Center(
                                  child: Text(
                                    'Upload',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
            ],



           if (_isSubmitted) ...[
  const Text(
    'ส่งงานเรียบร้อยแล้ว',
    style: TextStyle(fontWeight: FontWeight.bold,color:Colors.green),
  ),
  const SizedBox(height: 10),
  const Text(
    'หมายเหตุหากกด Unsubmit จะลบไฟล์ที่ส่งก่อนหน้านี้',
    style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red),
  ),
  const SizedBox(height: 10),
 

  
  const SizedBox(height: 10),
 SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _unsubmitFiles,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: HexColor('#40db90'),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                ),
                                child: Center(
                                  child: Text(
                                    'Unsubmit',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
],




          ],
        ),
      ),
    );
  }
}