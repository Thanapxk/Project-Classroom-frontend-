// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously, use_super_parameters

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class GroupMembersPage extends StatefulWidget {
  final String groupName;
  final String email;

  const GroupMembersPage({Key? key, required this.groupName, required this.email}) : super(key: key);

  @override
  _GroupMembersPageState createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage> {
  late Future<Map<String, dynamic>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = _fetchGroupMembersAndFriends();
  }

  Future<List<String>> _fetchFriends() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.31.68:3000/friends'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['friends']);
      } else {
        throw Exception('Failed to load friends: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchGroupMembers() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.31.68:3000/group-members'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'groupName': widget.groupName}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<String> members = List<String>.from(data['members']);
        members.remove(widget.email);
        return {'members': members};
      } else {
        throw Exception('Failed to load group members: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchGroupMembersAndFriends() async {
    try {
      final friends = await _fetchFriends();
      final groupMembers = await _fetchGroupMembers();
      return {'members': groupMembers['members'], 'friends': friends};
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> _addFriend(String friendEmail) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.31.68:3000/add-friend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email, 'friendEmail': friendEmail}),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เป็นเพื่อนสำเร็จ୧ʕ•̀ᴥ•́ʔ୨')),
        );
        setState(() {
          _membersFuture = _fetchGroupMembersAndFriends();
        });
      } else {
        throw Exception('แอดเพื่อนไม่สำเร็จ: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _removeFriend(String friendEmail) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.31.68:3000/remove-friend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email, 'friendEmail': friendEmail}),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบเพื่อนสำเร็จʕ ◔ᴥ◔ ʔ')),
        );
        setState(() {
          _membersFuture = _fetchGroupMembersAndFriends();
        });
      } else {
        throw Exception('Failed to remove friend: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
  'Friend ◕‿◕  ',
  style: GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ),
),
        backgroundColor:  Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
         
          Center(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _membersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text(
                    'Error: ${snapshot.error}',
                    style: GoogleFonts.poppins(), 
                  );
                } else {
                  final members = snapshot.data?['members'] ?? [];
                  final friends = snapshot.data?['friends'] ?? [];
                 return ListView.builder(
  itemCount: members.length,
  itemBuilder: (context, index) {
    final memberEmail = members[index];
    final isFriend = friends.contains(memberEmail);
    return ListTile(
      title: Text(
        memberEmail,
        style: GoogleFonts.poppins( 
    color: isFriend ? const Color.fromARGB(255, 207, 89, 182) : const Color.fromARGB(255, 0, 0, 0),fontWeight: FontWeight.bold,
  ),
),
      trailing: isFriend
          ? IconButton(
              icon: const Icon(Icons.favorite, color:Color.fromARGB(169, 206, 108, 177)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('ลบสถานะไปก็ลบเขาจากใจไม่ได้หรอกนะʕ≧ᴥ≦ʔ'),
                      content: const Text('คุณต้องการลบเขาออกจากการเป็นเพื่อนจริงใช่ไหม? คิดดีแล้วนะจะลบแล้วนะ! ไม่ต้องห่วงเรื่องนี้คุณและเขาจะรู้แค่สองคนเพราะเราจะลบ คสพ นี้ออกจากฐานข้อมูลเลย และไม่ต้องกังวลเขาจะแชทมารบกวนคุณไม่ได้หากไม่ได้เป็นเพื่อนคุณ ลาก่อนขอให้โชคดี '),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _removeFriend(memberEmail);
                          },
                          child: const Text('Remove'),
                        ),
                      ],
                    );
                  },
                );
              },
            )
          : IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () => isFriend ? null : _addFriend(memberEmail),
            ),
    );
  },
);

                }
              },
            ),
          ),
        ],
      ),
    );
  }
}


