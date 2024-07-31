// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, sort_child_properties_last, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TimetableScreen extends StatefulWidget {
  final String email;

  const TimetableScreen({required this.email});

  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  List<Timetable> _timetable = [];
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _subjectcodeController = TextEditingController();
  final _secController = TextEditingController();
  final _roomController = TextEditingController();
  final _dayController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final List<String> _days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  @override
  void initState() {
    super.initState();
    _fetchTimetable();
  }

  Future<void> _fetchTimetable() async {
    final response = await http.get(
        Uri.parse('http://192.168.31.68:3000/timetable?email=${widget.email}'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        _timetable = data.map((item) => Timetable.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load timetable');
    }
  }

  Future<void> _addTimetable() async {
    if (_formKey.currentState!.validate()) {
      final timetable = Timetable(
        id: 0,
        subject: _subjectController.text,
        subjectcode: _subjectcodeController.text,
        sec: _secController.text,
        room: _roomController.text,
        day: _dayController.text,
        startTime: _startTimeController.text,
        endTime: _endTimeController.text,
      );

      final response = await http.post(
        Uri.parse('http://192.168.31.68:3000/timetable'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(timetable.toJson()..['email'] = widget.email),
      );
      if (response.statusCode == 201) {
        _fetchTimetable();
        _subjectController.clear();
        _subjectcodeController.clear();
        _secController.clear();
        _roomController.clear();
        _dayController.clear();
        _startTimeController.clear();
        _endTimeController.clear();
      } else {
        throw Exception('Failed to add timetable');
      }
    }
  }

  Future<void> _deleteTimetable(int id) async {
    final response = await http.delete(
        Uri.parse('http://192.168.31.68:3000/timetable/$id?email=${widget.email}'));
    if (response.statusCode == 200) {
      _fetchTimetable();
    } else {
      throw Exception('Failed to delete timetable');
    }
  }

 Future<void> _pickTime(TextEditingController controller) async {
  TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: Colors.green, 
          hintColor: Colors.green, 
          colorScheme: const ColorScheme.light(primary: Colors.green), 
          buttonTheme: const ButtonThemeData(
            textTheme: ButtonTextTheme.primary,
          ),
        ),
        child: child!,
      );
    },
  );
  if (picked != null) {
    setState(() {
      controller.text = picked.format(context);
    });
  }
}


  void _showAddTimetableDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white, 
      title: const Text(
        'Add Timetable',
        style: TextStyle(color: Colors.black), 
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  labelStyle: TextStyle(color: Colors.black), 
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subject';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10), 
              TextFormField(
                controller: _subjectcodeController,
                decoration: const InputDecoration(
                  labelText: 'Subject Code',
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subject code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _secController,
                decoration: const InputDecoration(
                  labelText: 'Section',
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a section';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: 'Room',
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a room';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField(
                decoration: const InputDecoration(
                  labelText: 'Day',
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                items: _days.map((String day) {
                  return DropdownMenuItem(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _dayController.text = value as String;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a day';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _startTimeController,
                decoration: InputDecoration(
                  labelText: 'Start Time',
                  labelStyle: const TextStyle(color: Colors.black),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.access_time, color: Colors.green[800]),
                    onPressed: () => _pickTime(_startTimeController),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a start time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _endTimeController,
                decoration: InputDecoration(
                  labelText: 'End Time',
                  labelStyle: const TextStyle(color: Colors.black),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.access_time, color: Colors.green[800]),
                    onPressed: () => _pickTime(_endTimeController),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an end time';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text('Add'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.green,
          ),
          onPressed: () {
            _addTimetable();
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    Map<String, List<Timetable>> groupedTimetable = {};
    for (var item in _timetable) {
      if (!groupedTimetable.containsKey(item.day)) {
        groupedTimetable[item.day] = [];
      }
      groupedTimetable[item.day]!.add(item);
    }

    return Scaffold(
      appBar: AppBar(
        
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
        ),
        backgroundColor: Colors.green,
        title: const Text('Teaching schedule',style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        
        actions: [
          
          IconButton(
            icon: const Icon(Icons.add_alert),
            onPressed: _showAddTimetableDialog,
          ),
          
        ],
        
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: _days.map((day) {
              
              final dayTimetable = groupedTimetable[day] ?? [];
              if (dayTimetable.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      color: _getDayColor(day),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ...dayTimetable.map((item) => _buildTimetableCard(item)).toList(),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

 Widget _buildTimetableCard(Timetable item) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    color: Colors.white,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.subject,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text('รหัสวิชา: ${item.subjectcode}'),
                Text('หมู่เรียน: ${item.sec}'),
                Text('ห้องเรียน: ${item.room}'),
                Text('เวลาเรียน: ${item.startTime} - ${item.endTime}'),
              ],
            ),
          ),
        ),
      
        PopupMenuButton(icon: const Icon(
                         Icons.more_horiz,
                         color: Colors.black, 
                         ),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete'),
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') {
              _deleteTimetable(item.id);
            }
          },
        ),
      ],
    ),
  );
}




  Color _getDayColor(String day) {
    switch (day) {
      case 'Monday':
        return Colors.yellow;
      case 'Tuesday':
        return Colors.pinkAccent;
      case 'Wednesday':
        return Colors.green;
      case 'Thursday':
        return Colors.orange;
      case 'Friday':
        return Colors.blue;
      case 'Saturday':
        return Colors.purple;
      case 'Sunday':
        return Colors.red;
      default:
        return Colors.white;
    }
  }
}

class Timetable {
  final int id;
  final String subject;
  final String day;
  final String startTime;
  final String endTime;
  final String subjectcode;
  final String sec;
  final String room;

  Timetable({
    required this.id,
    required this.subject,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.subjectcode,
    required this.sec,
    required this.room,
  });

  factory Timetable.fromJson(Map<String, dynamic> json) {
    return Timetable(
      id: json['id'],
      subject: json['subject'],
      day: json['day'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      subjectcode: json['subjectcode'],
      sec: json['sec'],
      room: json['room'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'subjectcode': subjectcode,
      'sec': sec,
      'room': room,
    };
  }
}
