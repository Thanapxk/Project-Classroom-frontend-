// ignore_for_file: file_names, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_final_fields, avoid_function_literals_in_foreach_calls, avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageScreen extends StatefulWidget {
  final String groupName;
  final String email;

  const ImageScreen({required this.groupName, required this.email});

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    try {
      var apiUrl = Uri.parse('http://192.168.31.68:3000/messages?groupName=${widget.groupName}');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        List<dynamic> imagesData = json.decode(response.body)['messages'];

        setState(() {
          _imageUrls.clear();
          imagesData.forEach((imageData) {
            if (imageData['image_url'] != null) {
              _imageUrls.add(imageData['image_url']);
            }
          });
        });
      } else {
        print('Failed to load images. Error ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('http://192.168.31.68:3000$imageUrl'),
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Images from ${widget.groupName}',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _imageUrls.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _imageUrls.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _showImageDialog(_imageUrls[index]);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.network(
                      'http://192.168.31.68:3000${_imageUrls[index]}',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
