// ignore_for_file: file_names, use_super_parameters, library_private_types_in_public_api, avoid_print, unused_element

import 'package:flutter/material.dart';
import 'package:flutter_lohin/chat/chatscreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class RoomChat extends StatefulWidget {
  final String email;

  const RoomChat({Key? key, required this.email}) : super(key: key);

  @override
  _RoomChatState createState() => _RoomChatState();
}

class _RoomChatState extends State<RoomChat> {
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

 Future<Map<String, dynamic>?> _fetchLatestMessage(String groupName) async {
  try {
    final response = await http.get(
      Uri.parse('http://192.168.31.68:3000/messages/latest?groupName=$groupName'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['message'] != null) {
        return {
          'sender': data['message']['sender_email'],
          'message': data['message']['message'],
        };
      } else {
        return null; 
      }
    } else {
      throw Exception('Failed to load latest message: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}


  void _navigateToChatPage(String groupName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          email: widget.email,
          groupName: groupName,
        ),
      ),
    );
  }

  void _handleNotifications(String groupName) {
   
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notifications for $groupName'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Room Chat',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
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
                      'You don\'t have any chat groups',
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
                return FutureBuilder<Map<String, dynamic>?>(
                  future: _fetchLatestMessage(groupData['groupname']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: SizedBox(
                            width: double.infinity,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  _navigateToChatPage(groupData['groupname']);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.green.shade200,
                                      width: 2,
                                    ),
                                    color: Colors.green.shade50,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Chat Group Name: ${groupData['groupname']}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      const Text(
                                        'Loading...',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final latestMessage = snapshot.data;
                      return Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: SizedBox(
                            width: double.infinity,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  _navigateToChatPage(groupData['groupname']);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.green.shade200,
                                      width: 2,
                                    ),
                                    color: Colors.green.shade50,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ' ${groupData['groupname']}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      if (latestMessage != null)
                                        Text(
                                          '${latestMessage['sender']}: ${latestMessage['message']}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      if (latestMessage == null)
                                        const Text(
                                          'No messages yet',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
