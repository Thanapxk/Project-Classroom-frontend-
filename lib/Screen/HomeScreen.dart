// ignore_for_file: file_names, use_super_parameters, library_private_types_in_public_api, avoid_print, use_build_context_synchronously, sort_child_properties_last, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_lohin/Screen/Roomchat.dart';

import 'package:flutter_lohin/group/CrateGroup.dart';
import 'package:flutter_lohin/group/Group.dart';
import 'package:flutter_lohin/table/table.dart';


import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_lohin/group/JoinGroupPage.dart';

import 'package:flutter_lohin/profile/Profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Login.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  final String email;

  const HomeScreen({Key? key, required this.email}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> userGroups = [];

  @override
  void initState() {
    super.initState();
    _fetchGroupName();
  }

  Future<void> _fetchGroupName() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.31.68:3000/room?email=${widget.email}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userGroups = List<Map<String, dynamic>>.from(data['userGroups']);
        });
      } else if (response.statusCode == 404) {
        setState(() {
          userGroups = [];
        });
      } else {
        throw Exception('Failed to load group data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _refreshGroups() {
    _fetchGroupName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Email~${widget.email}',
          style: GoogleFonts.poppins(
            
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 21, 20, 20),
          ),
        ),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        leading:IconButton(
            icon: const Icon(Icons.menu),
            color: Colors.black,
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
          ),
      
  

          
      
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text(''),
              accountEmail: Text(widget.email),
              decoration: const BoxDecoration(
                color: Colors.green,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileScreen(email: widget.email)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                try {
                  await http.post(
                    Uri.parse('http://192.168.31.68:3000/logout'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'email': widget.email}),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                } catch (e) {
                  print('Error: $e');
                }
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: userGroups.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'You don\'t have group',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: userGroups.length,
              itemBuilder: (context, index) {
                final groupData = userGroups[index];
                return Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Group(
                                email: widget.email,
                                groupName: groupData['groupname'],
                                passwordgroup:groupData['passwordgroup'],
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: Colors.green.shade200,
                              width: 2,
                            ),
                          ),
                          padding: const EdgeInsets.all(10),
                          backgroundColor: Colors.green.shade50,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Group Name: ${groupData['groupname']}',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text('Subject: ${groupData['subject']}'),
                            const SizedBox(height: 10),
                            Text('Subject code: ${groupData['subject_code']}'),
                            
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: SpeedDial(
        child: const Icon(Icons.add, color: Colors.green),
        activeIcon: Icons.close,
        iconTheme: const IconThemeData(color: Colors.green),
        backgroundColor: const Color.fromARGB(255, 198, 224, 199),
        buttonSize: const Size(58, 58),
        curve: Curves.bounceIn,
        children: [
          SpeedDialChild(
            elevation: 0,
            child: Icon(
              Icons.local_library,
              color: Colors.green,
            ),
            labelWidget: Text(
              'Join class',
              style: TextStyle(color: Colors.green),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => JoinGroupPage(email: widget.email, refreshGroups: _refreshGroups)),
              );
            },
          ),
          SpeedDialChild(
            elevation: 0,
            child: Icon(
              Icons.create,
              color: Colors.green,
            ),
            labelWidget: Text(
              'Create a class',
              style: TextStyle(color: Colors.green),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateGroup(
                        email: widget.email, refreshGroups: _refreshGroups)),
              );
            },
          ),
          SpeedDialChild(
            elevation: 0,
            child: Icon(
              Icons.chat_bubble,
              color: Colors.green,
            ),
            labelWidget: Text(
              'Room Chat',
              style: TextStyle(color: Colors.green),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RoomChat(
                        email: widget.email)),
              );
            },
          ),
           SpeedDialChild(
            elevation: 0,
            child: Icon(
              Icons.school,
              color: Colors.green,
            ),
            labelWidget: Text(
              'Timetable',
              style: TextStyle(color: Colors.green),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TimetableScreen(
                        email: widget.email)),
              );
            },
          ),
          SpeedDialChild(
            elevation: 0,
            child: Icon(
              Icons.refresh,
              color: Colors.green,
            ),
            labelWidget: Text(
              'Refresh Group',
              style: TextStyle(color: Colors.green),
            ),
            onTap:_refreshGroups,
            
          ),


          
        ],
      ),
    );
  }
}
