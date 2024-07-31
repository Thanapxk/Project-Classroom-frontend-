// ignore_for_file: file_names, depend_on_referenced_packages, use_super_parameters, non_constant_identifier_names, avoid_print, prefer_final_fields, unused_element, sort_child_properties_last, use_build_context_synchronously, avoid_unnecessary_containers

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_lohin/Screen/HomeScreen.dart';
import 'package:flutter_lohin/chat/chatscreen.dart';
import 'package:flutter_lohin/checkIn/CheckInScreen.dart';
import 'package:flutter_lohin/group/CheckWork.dart';
import 'package:flutter_lohin/group/Classwork.dart';
import 'package:flutter_lohin/group/GroupInfo.dart';
import 'package:flutter_lohin/group/GroupMember.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class Group extends StatefulWidget {
  const Group({
    Key? key,
    required this.groupName,
    required this.email,
    required this.passwordgroup,
  }) : super(key: key);

  final String groupName;
  final String email;
  final String passwordgroup;

  @override
  State<Group> createState() => _GroupState();
}

class _GroupState extends State<Group> {
  final formKey = GlobalKey<FormState>();
  TextEditingController description = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  List<Map<String, dynamic>> datapost = [];
  Map<String, List<Map<String, dynamic>>> comments = {};
  Map<String, bool> showComments = {};
  //Map<String, dynamic>? groupInfo;

  bool isIconButtonVisible = false;

  @override
  void initState() {
    super.initState();
    getpost();
    //fetchGroupInfo();
    check_owner();
  }

  Future<void> check_owner() async {
    try {
      String uri = 'http://192.168.31.68:3000/check-owner22';
      var res = await http.post(
        Uri.parse(uri),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'passwordgroup': widget.passwordgroup,
        }),
      );
      var response = jsonDecode(res.body);
      if (response['success'] == true) {
        setState(() {
          isIconButtonVisible = true;
        });
      } else {
        setState(() {
          isIconButtonVisible = false;
        });
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  final picker = ImagePicker();

  Future<void> _pickFiles(StateSetter setModalState) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
      setModalState(() {
        _files.addAll(files);
      });
    }
  }

  List<File> _files = [];
  Future<void> posts() async {
    try {
      String uri = 'http://192.168.31.68:3000/posts22';
      var request = http.MultipartRequest('POST', Uri.parse(uri));
      request.fields['email'] = widget.email;
      request.fields['description'] = description.text;
      request.fields['passwordgroup'] = widget.passwordgroup;

      for (var file in _files) {
        request.files.add(await http.MultipartFile.fromPath(
          'files',
          file.path,
          contentType: MediaType('application', 'octet-stream'),
        ));
      }

      var res = await request.send();
      var response = await http.Response.fromStream(res);

      if (res.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          Fluttertoast.showToast(msg: 'Success');
          getpost(); 
        } else {
          Fluttertoast.showToast(msg: 'Failed to post');
        }
      } else {
        Fluttertoast.showToast(msg: 'Failed to post');
      }
    } on Exception catch (e) {
      print(e);
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      String uri = 'http://192.168.31.68:3000/posts22/$postId';
      var res = await http.delete(
        Uri.parse(uri),
        headers: {'Content-Type': 'application/json'},
      );
      var response = jsonDecode(res.body);
      if (response['success'] == true) {
        Fluttertoast.showToast(msg: 'Post deleted successfully.');
        getpost();
      } else {
        Fluttertoast.showToast(msg: 'Error deleting post.');
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> editPost(String postId, String newDescription) async {
    try {
      String uri = 'http://192.168.31.68:3000/edit-post22';
      var res = await http.put(
        Uri.parse(uri),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': postId,
          'description': newDescription,
        }),
      );
      var response = jsonDecode(res.body);
      if (response['success'] == true) {
        Fluttertoast.showToast(msg: 'Post updated successfully');
        getpost(); 
      } else {
        Fluttertoast.showToast(msg: 'Failed to update post');
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  void showEditDialog(String postId, String currentDescription) {
    TextEditingController editController =
        TextEditingController(text: currentDescription);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Post'),
          content: TextFormField(
            controller: editController,
            minLines: 1,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                Navigator.of(context).pop();
                await editPost(postId, editController.text);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> getpost() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.31.68:3000/get-posts22?passwordgroup=${widget.passwordgroup}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          datapost = List<Map<String, dynamic>>.from(data['datapost']);
          for (var post in datapost) {
            getComments(post['id'].toString());
            showComments[post['id'].toString()] =
                false; 
          }
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> getComments(String postid) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.31.68:3000/get-comments22?postid=$postid'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          comments[postid] = List<Map<String, dynamic>>.from(data['comments']);
        });
      } else {
        throw Exception('Failed to load comments: ${response.statusCode}');
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> deleteComment(String commentId, String postId) async {
    try {
      String uri = 'http://192.168.31.68:3000/comments22/$commentId';
      var res = await http.delete(
        Uri.parse(uri),
        headers: {'Content-Type': 'application/json'},
      );
      var response = jsonDecode(res.body);
      if (response['success'] == true) {
        Fluttertoast.showToast(msg: 'Comment deleted successfully.');
        await getComments(postId); 
      } else {
        Fluttertoast.showToast(msg: 'Error deleting comment.');
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> postComment(String postId, String comment) async {
    try {
      String uri = 'http://192.168.31.68:3000/post-comment22';
      var res = await http.post(
        Uri.parse(uri),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'postid': postId,
          'email': widget.email,
          'comment': comment,
        }),
      );
      var response = jsonDecode(res.body);
      if (response['success'] == true) {
        Fluttertoast.showToast(msg: 'Comment posted');
        await getComments(postId);
      } else {
        Fluttertoast.showToast(msg: 'Failed to post comment');
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  String _formatTime(String timestamp) {

    DateTime dateTime = DateTime.parse(timestamp).toLocal();

    
   

  
    DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');

    return formatter.format(dateTime);
  }

  Future<bool> _fileExists(String path) async {
    return File(path).exists();
  }

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? dueDate;

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

   Future<void> createAssignment(String title, String description,
      DateTime? dueDate, List<File> files) async {
    final uri = Uri.parse('http://192.168.31.68:3000/create-assignment');
    final request = http.MultipartRequest('POST', uri);

    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['passwordgroup'] = widget.passwordgroup;

    if (dueDate != null) {
      request.fields['due_date'] = dueDate.toIso8601String();
    }
    for (var file in files) {
      request.files.add(await http.MultipartFile.fromPath('files', file.path));
    }

    var res = await request.send();
    var response = await http.Response.fromStream(res);

    if (res.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        Fluttertoast.showToast(msg: 'Success');
      } else {
        Fluttertoast.showToast(msg: 'Failed to post');
      }
    } else {
      Fluttertoast.showToast(msg: 'Failed to post');
    }
  }

  void _refreshGroups() {
    getpost();
  }







  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      
      length: 3,
      
      child: Scaffold(
        appBar: AppBar(
          title: Text('Group  ${widget.groupName}',style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 21, 20, 20),
          ),),
          backgroundColor: Colors.green,
          bottom:  const TabBar(
            labelColor: Colors.white, 
            unselectedLabelColor: Colors.black,
             indicatorColor: Colors.greenAccent, 
            indicatorWeight: 3.0,
            tabs: [
              Tab(text: 'Stream',),
              Tab(text: 'Classwork'),
              Tab(text: 'Grades'),
            ],
            
          ),
          leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
        ),
        ),
        floatingActionButton: SpeedDial(
          child: const Icon(Icons.add, color: Colors.green),
          icon: Icons.add,
          activeIcon: Icons.close,
          iconTheme: const IconThemeData(color: Colors.green),
          backgroundColor: const Color.fromARGB(255, 198, 224, 199),
          buttonSize: const Size(58, 58),
          curve: Curves.bounceIn,
          children: [
            SpeedDialChild(
              elevation: 0,
              visible: isIconButtonVisible,
              child: const Icon(Icons.post_add, color: Colors.deepPurple),
              labelWidget: const Text('Create post',
                  style: TextStyle(color: Colors.deepPurple)),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder:
                          (BuildContext context, StateSetter setModalState) {
                        return SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Container(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Form(
                                key: formKey,
                                
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[500],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      margin: const EdgeInsets.only(bottom: 10),
                                    ),
                                    TextFormField(
                                      controller: description,
                                      minLines: 1,
                                      maxLines: 10,
                                      decoration: const InputDecoration(
                                        labelText: 'Description',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a description';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _files.isEmpty
                                        ? const Text('No file selected.')
                                        : Column(
                                            children: _files.map((file) {
                                              String extension = path
                                                  .extension(file.path)
                                                  .toLowerCase();
                                              bool isImage = [
                                                '.jpg',
                                                '.jpeg',
                                                '.png',
                                                '.gif'
                                              ].contains(extension);

                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  color: Colors.deepPurple[100],
                                                  child: Stack(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12.0),
                                                        child: Column(
                                                          children: [
                                                            isImage
                                                                ? Center(
                                                                    child: Image
                                                                        .file(
                                                                      file,
                                                                      width:
                                                                          100,
                                                                      height:
                                                                          100,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  )
                                                                : Text(
                                                                    path.basename(
                                                                        file.path),
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                          ],
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        right: 0,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            setModalState(() {
                                                              _files
                                                                  .remove(file);
                                                            });
                                                          },
                                                          child: Container(
                                                            width: 24,
                                                            height: 24,
                                                            decoration:
                                                                const BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Colors.red,
                                                            ),
                                                            child: const Center(
                                                              child: Icon(
                                                                Icons.close,
                                                                color: Colors
                                                                    .white,
                                                                size: 16,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () =>
                                              _pickFiles(setModalState),
                                          child: const Text('Pick File'),
                                        ),
                                      ],
                                    ),
                                     SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.deepPurple,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        onPressed: () async {
                                          if (formKey.currentState!
                                              .validate()) {
                                            await posts();
                                            formKey.currentState!.reset();
                                            Navigator.pop(context);
                                            description.clear();
                                            _files.clear();
                                          }
                                        },
                                        child: const Text(
                                          'Post',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            SpeedDialChild(
              elevation: 0,
              visible: isIconButtonVisible,
              child: const Icon(Icons.assignment_add, color: Colors.deepPurple),
              labelWidget: const Text('Assignment',
                  style: TextStyle(color: Colors.deepPurple)),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return Padding(
                      padding: MediaQuery.of(context).viewInsets,
                      child: StatefulBuilder(
                        builder:
                            (BuildContext context, StateSetter setModalState) {
                          return Form(
                            key: formKey,
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[500],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      margin: const EdgeInsets.only(bottom: 10),
                                    ),
                                    TextFormField(
                                      controller: titleController,
                                      decoration: const InputDecoration(
                                        labelText: 'Title',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a title';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: descriptionController,
                                      decoration: const InputDecoration(
                                        labelText: 'Description',
                                        border: OutlineInputBorder(),
                                      ),
                                      maxLines: 3,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a description';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            dueDate == null
                                                ? 'No due date selected'
                                                : 'Due Date: ${dueDate.toString().split(' ')[0]}',
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            dueDate = await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime(2101),
                                            );
                                            setModalState(() {});
                                          },
                                          child: const Text('Select Due Date'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _files.isEmpty
                                        ? const Text('No file selected.')
                                        : Column(
                                            children: _files.map((file) {
                                              String extension = path
                                                  .extension(file.path)
                                                  .toLowerCase();
                                              bool isImage = [
                                                '.jpg',
                                                '.jpeg',
                                                '.png',
                                                '.gif'
                                              ].contains(extension);

                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  color: Colors.deepPurple[100],
                                                  child: Stack(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12.0),
                                                        child: Column(
                                                          children: [
                                                            isImage
                                                                ? Center(
                                                                    child: Image
                                                                        .file(
                                                                      file,
                                                                      width:
                                                                          100,
                                                                      height:
                                                                          100,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  )
                                                                : Text(
                                                                    path.basename(
                                                                        file.path),
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                          ],
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        right: 0,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            setModalState(() {
                                                              _files
                                                                  .remove(file);
                                                            });
                                                          },
                                                          child: Container(
                                                            width: 24,
                                                            height: 24,
                                                            decoration:
                                                                const BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Colors.red,
                                                            ),
                                                            child: const Center(
                                                              child: Icon(
                                                                Icons.close,
                                                                color: Colors
                                                                    .white,
                                                                size: 16,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () =>
                                              _pickFiles(setModalState),
                                          child: const Text('Pick File'),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.deepPurple,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        onPressed: () async {
                                          if (formKey.currentState!
                                              .validate()) {
                                            await createAssignment(
                                              titleController.text,
                                              descriptionController.text,
                                              dueDate,
                                              _files,
                                            );
                                            formKey.currentState!.reset();
                                            Navigator.pop(context);
                                            titleController.clear();
                                            descriptionController.clear();
                                            dueDate = null;
                                            _files.clear();
                                          }
                                        },
                                        child: const Text(
                                          'Post',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
            SpeedDialChild(
            elevation: 0,
            visible: isIconButtonVisible,
            child: const Icon(
              Icons.work_history_outlined,
              color: Colors.deepPurple,
            ),
            labelWidget: const Text(
              'Work',
              style: TextStyle(color: Colors.deepPurple),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Checkwork(email: widget.email, passwordgroup:widget.passwordgroup, )),
              );
            },
          ),
            SpeedDialChild(
            elevation: 0,
            child: const Icon(
              Icons.chat,
              color: Colors.green,
            ),
            labelWidget: const Text(
              'Chat',
              style: TextStyle(color: Colors.green),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatScreen(email: widget.email, groupName: widget.groupName)),
              );
            },
          ),
          SpeedDialChild(
            elevation: 0,
            child: const Icon(
              Icons.person_pin_rounded,
              color: Colors.green,
            ),
            labelWidget: const Text(
              'Group Info',
              style: TextStyle(color: Colors.green),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GroupInfo(passwordgroup:widget.passwordgroup)),
              );
            },
          ),

          SpeedDialChild(
            elevation: 0,
            child: const Icon(
              Icons.person,
              color: Colors.green,
            ),
            labelWidget: const Text(
              'Member Group',
              style: TextStyle(color: Colors.green),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GroupMembersPage(groupName: widget.groupName, email: widget.email)),
              );
            },
          ),

          SpeedDialChild(
            elevation: 0,
            child: const Icon(
              Icons.refresh,
              color: Colors.green,
            ),
            labelWidget: const Text(
              'Refresh Group',
              style: TextStyle(color: Colors.green),
            ),
            onTap:_refreshGroups,
            
          ),

          SpeedDialChild(
  elevation: 0,
  child: const Icon(
    Icons.exit_to_app,
    color: Colors.red,
  ),
  labelWidget: const Text(
    'ออกจากกลุ่ม',
    style: TextStyle(color: Colors.red),
  ),
  onTap: () async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการออกจากกลุ่ม'),
          content: const Text('คุณแน่ใจหรือว่าต้องการออกจากกลุ่มนี้?'),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('ยืนยัน'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm) {
      try {
        final response = await http.post(
          Uri.parse('http://192.168.31.68:3000/leave-group'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': widget.email,
            'groupname': widget.groupName,
          }),
        );

        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: 'ออกจากกลุ่มสำเร็จ');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(email: widget.email)),
            (Route<dynamic> route) => false,
          );
        } else {
          Fluttertoast.showToast(msg: 'ออกจากกลุ่มไม่สำเร็จ');
        }
      } catch (e) {
        print('Error leaving group: $e');
        Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาดในการออกจากกลุ่ม');
      }
    }
  },
),



   SpeedDialChild(
            elevation: 0,
            child: const Icon(
              Icons.check_box_outline_blank_rounded,
              color: Colors.green,
            ),
            labelWidget: const Text(
              'Check In',
              style: TextStyle(color: Colors.green),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CheckInPage(groupName: widget.groupName, email: widget.email)),
              );
            },
          ),




          ],
          
        ),
        
        
        body: TabBarView(
          children: [

                    
            datapost.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No posts available',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: getpost,
                    child:SingleChildScrollView(
                    child: ListView.builder(
                       physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                      itemCount: datapost.length,
                      itemBuilder: (context, index) {
                        final post = datapost[index];
                        final postId = post['id'].toString();
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${post['email']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Visibility(
                                        visible: isIconButtonVisible,
                                        child: PopupMenuButton<String>(
                                          onSelected: (String result) {
                                            if (result == 'edit') {
                                              
                                              showEditDialog(
                                                  post['id'].toString(),
                                                  post['description']);
                                            } else if (result == 'delete') {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Confirm Delete'),
                                                      content: const Text(
                                                          'Are you sure you want to delete this post?'),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child: const Text(
                                                              'Cancel'),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: const Text(
                                                              'Delete'),
                                                          onPressed: () async {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            await deletePost(
                                                                post['id']
                                                                    .toString());
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            }
                                          },
                                          itemBuilder: (BuildContext context) =>
                                              <PopupMenuEntry<String>>[
                                            const PopupMenuItem<String>(
                                              value: 'edit',
                                              child: Text('Edit'),
                                            ),
                                            const PopupMenuItem<String>(
                                              value: 'delete',
                                              child: Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    ' ${_formatTime(post['create_at'])}',
                                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    ' ${post['description']}',
                                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                                  ),
                                  const SizedBox(height: 2),
                                  if (post['files'] != null &&
                                      post['files'].isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        ...post['files'].map<Widget>((file) {
                                          String filename = file['filename'];
                                          String extension = filename
                                              .split('.')
                                              .last
                                              .toLowerCase();
                                          List<String> imageExtensions = [
                                            'jpg',
                                            'png',
                                            'gif',
                                            'jpeg'
                                          ];

                                          if (imageExtensions
                                              .contains(extension)) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: Center(
                                                child: Image.network(
                                                  'http://192.168.31.68:3000/uploads/$filename',
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: GestureDetector(
                                                onTap: () async {
                                                  final file = await loadPdfFromUrl(
                                                      'http://192.168.31.68:3000/uploads/$filename',
                                                      filename);
                                                  _showPdfDialog(context, file);
                                                },
                                                child: Text(filename),
                                              ),
                                            );
                                          }
                                        }).toList()
                                      ],
                                    ),
                                  const Divider(),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            showComments[postId] =
                                                !showComments[postId]!;
                                          });
                                        },
                                        child: Text(
                                          showComments[postId]!
                                              ? 'Hide Comments'
                                              : 'Show Comments',
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '${comments[postId]?.length ?? 0} comments',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (showComments[postId]!)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Comments:',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          ...comments[postId]?.map((comment) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 5),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          '${comment['email']} : ${comment['comment']} ',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14),
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible:
                                                            comment['email'] ==
                                                                widget.email,
                                                        child: PopupMenuButton<
                                                            String>(
                                                          onSelected: (String
                                                              result) async {
                                                            if (result ==
                                                                'delete') {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      title: const Text(
                                                                          'Confirm Delete'),
                                                                      content:
                                                                          const Text(
                                                                              'Are you sure you want to delete this comment?'),
                                                                      actions: <Widget>[
                                                                        TextButton(
                                                                          child:
                                                                              const Text('Cancel'),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                        ),
                                                                        TextButton(
                                                                          child:
                                                                              const Text('Delete'),
                                                                          onPressed:
                                                                              () async {
                                                                            Navigator.of(context).pop();
                                                                            await deleteComment(comment['id'].toString(),
                                                                                postId);
                                                                          },
                                                                        ),
                                                                      ],
                                                                    );
                                                                  });
                                                            }
                                                          },
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context) =>
                                                                  <PopupMenuEntry<
                                                                      String>>[
                                                            const PopupMenuItem<
                                                                String>(
                                                              value: 'delete',
                                                              child: Text(
                                                                  'Delete'),
                                                            ),
                                                          ],
                                                          iconSize: 15,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList() ??
                                              [],
                                          const SizedBox(height: 10),
                                          TextFormField(
                                            controller: commentController,
                                            decoration: const InputDecoration(
                                              labelText: 'Add a comment',
                                              border: OutlineInputBorder(),
                                            ),
                                            onFieldSubmitted: (value) {
                                              if (value.isNotEmpty) {
                                                postComment(postId, value);
                                                commentController.clear();
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            
            Classwork(passwordgroup: widget.passwordgroup, email: widget.email,),
              
            
            SingleChildScrollView(
              child: Container(
                child: const Center(child: Text('Grades tab content')),
              ),
            )
          ],
        ),
      ),
    );
  }
}
