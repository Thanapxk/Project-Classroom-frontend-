// ignore_for_file: use_super_parameters, library_private_types_in_public_api, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_lohin/chat/Image.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final String email;
  final String groupName;

  const ChatScreen({Key? key, required this.email, required this.groupName}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
    final TextEditingController _messageController = TextEditingController();
  
  List<Message> _messages = [];
  int _memberCount = 0;
  final Duration _fetchInterval = const Duration(seconds: 2); 
  final ImagePicker _picker = ImagePicker();
  Timer? _messageFetchTimer;
  Timer? _memberCountFetchTimer;
  File? _imageFile;
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    _connectSocket();
    _fetchInitialData();
    _startPeriodicFetch();
  }

  @override
  void dispose() {
    _stopPeriodicFetch();
    socket.disconnect();
    super.dispose();
  }

  void _connectSocket() {
    socket = IO.io('http://192.168.31.68:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    socket.on('message', (data) => _handleReceivedMessage(data));
  }

  void _handleReceivedMessage(dynamic data) {
    Message newMessage = Message(
      senderId: data['sender_email'],
      message: data['message'],
      time: DateTime.parse(data['time']),
      date: data['date'],
      imageUrl: data['image_url'],
    );
    setState(() {
      _messages.add(newMessage);
    });
  }

  void _fetchInitialData() {
    _fetchMessages();
    _fetchMemberCount();
  }

  void _startPeriodicFetch() {
    Timer.periodic(_fetchInterval, (_) {
      _fetchMessages();
      _fetchMemberCount();
    });
  }

  void _stopPeriodicFetch() {
    _messageFetchTimer?.cancel();
    _memberCountFetchTimer?.cancel();
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.31.68:3000/messages?groupName=${widget.groupName}'),
      );

      if (response.statusCode == 200) {
        List<Message> fetchedMessages = (jsonDecode(response.body)['messages'] as List)
            .map((data) => Message(
                  senderId: data['sender_email'],
                  message: data['message'],
                  time: DateTime.parse(data['time']),
                  date: data['date'],
                  imageUrl: data['image_url'],
                ))
            .toList();
        setState(() {
          _messages = fetchedMessages;
        });
      } else {
        print('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  Future<void> _fetchMemberCount() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.31.68:3000/group-members-count?groupName=${widget.groupName}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _memberCount = jsonDecode(response.body)['member_count'];
        });
      } else {
        print('Failed to load member count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching member count: $e');
    }
  }

  Future<void> sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText.isNotEmpty || _imageFile != null) {
      final url = Uri.parse('http://192.168.31.68:3000/send-message');
      final request = http.MultipartRequest('POST', url)
        ..fields['sender_email'] = widget.email
        ..fields['group_name'] = widget.groupName
        ..fields['message'] = messageText
        ..fields['time'] = DateTime.now().toIso8601String();

      if (_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));
      }

      try {
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 201) {
          setState(() {
            _messages.add(Message(
              senderId: widget.email,
              message: messageText,
              time: DateTime.now(),
              date: DateTime.now().toIso8601String().substring(0, 10),
              imageUrl: _imageFile != null ? '/uploads/${_imageFile!.path.split('/').last}' : null,
            ));
          });
          _messageController.clear();
          _imageFile = null; 
        } else {
          print('Failed to send message: ${response.statusCode}');
        }
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }
  
  bool _isNewDate(int index) {
  if (index == 0) return true; 
  DateTime currentDate = _messages[index].time;
  DateTime previousDate = _messages[index - 1].time;
  
 
  return currentDate.day != previousDate.day ||
         currentDate.month != previousDate.month ||
         currentDate.year != previousDate.year;
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.groupName,
              style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20,),
              
            ),
            Text(
              'Members: $_memberCount',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF66BB6A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
         actions: [
      IconButton(
  icon: const Icon(Icons.image, color: Colors.white), 
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ImageScreen(email: widget.email, groupName: widget.groupName,)),
    );
  },
),

    ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://s.isanook.com/ga/0/ud/223/1117697/kimetsu-no-yaiba-(3).jpg?ip/crop/w728h431/q80/webp'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              children: [
               Expanded(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: ListView.builder(
      itemCount: _messages.length,
      
      itemBuilder: (BuildContext context, int index) {
        bool isNewDate = _isNewDate(index);

        return Column(
          children: [
            if (isNewDate)
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5), 
                    borderRadius: BorderRadius.circular(20),
                    
                  ),
                  child: Text(
                    _formatDate(_messages[index].time),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, 
                    ),
                  ),
                ),
              ),
            MessageWidget(message: _messages[index], userEmail: widget.email),
          ],
        );
      },
    ),
  ),
),



                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Image.file(
                          _imageFile!,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.cancel),
                              onPressed: () {
                                setState(() {
                                  _imageFile = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        onPressed: _pickImage,
                        mini: true,
                        backgroundColor: const Color(0xFF66BB6A),
                        child: const Icon(Icons.image, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        onPressed: sendMessage,
                        mini: true,
                        backgroundColor: const Color(0xFF66BB6A),
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
                    ],
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

class Message {
  final String senderId;
  final String message;
  final DateTime time;
  final String date;
  final String? imageUrl;

  Message({
    required this.senderId,
    required this.message,
    required this.time,
    required this.date,
    this.imageUrl,
  });
}
class MessageWidget extends StatelessWidget {
  final Message message;
  final String userEmail;

  const MessageWidget({
    Key? key,
    required this.message,
    required this.userEmail,
  }) : super(key: key);

  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: SizedBox(
              width: 300,
              height: 300,
              child: Image.network(
                'http://192.168.31.68:3000${message.imageUrl}',
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMe = message.senderId == userEmail;

    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (!isMe) 
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage('http://192.168.31.68:3000/user/${message.senderId}.jpg'),
                ),
                const SizedBox(width: 8),
                Text(
                  message.senderId,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: GestureDetector(
            onTap: () {
              if (message.imageUrl != null) {
                _showImageDialog(context);
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF66BB6A) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'http://192.168.31.68:3000${message.imageUrl}',
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (message.message.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        message.message,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${message.time.hour.toString().padLeft(2, '0')}:${message.time.minute.toString().padLeft(2, '0')} น',
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
