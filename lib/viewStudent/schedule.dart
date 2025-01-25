import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String userRole = "";
  String userId = "";
  List<String> enrolledCourses = [];

  Map<int, List<Map<String, dynamic>>> schedule = {
    0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: [],
  };

  DateTime _currentWeekStart = DateTime.now();
  DateTime _currentWeekEnd = DateTime.now().add(const Duration(days: 6));

  @override
  void initState() {
    super.initState();
    _setWeekDates(DateTime.now());
    _getUserData();
  }

  void _setWeekDates(DateTime date) {
    final int weekday = date.weekday;
    final DateTime startOfWeek = date.subtract(Duration(days: weekday - 1));
    final DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    setState(() {
      _currentWeekStart = startOfWeek;
      _currentWeekEnd = endOfWeek;
    });

    _loadClasses();
  }

  Future<void> _getUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      userId = user.uid;
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        setState(() {
          userRole = userDoc.data()?['role'] ?? "";
          enrolledCourses = List<String>.from(userDoc.data()?['enrolledCourses'] ?? []);
        });
        _loadClasses();
      }
    }
  }

  Future<void> _loadClasses() async {
    try {
      final snapshot = await _firestore.collection('classes').get();

      setState(() {
        schedule = {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []};

        for (var doc in snapshot.docs) {
          final Map<String, dynamic> classData = doc.data() as Map<String, dynamic>;

          List<dynamic> dates = classData['date'] ?? [];
          bool isInRange = dates.any((d) {
            try {
              DateTime classDate = DateFormat('yyyy-MM-dd').parse(d);
              return classDate.isAfter(_currentWeekStart.subtract(const Duration(days: 1))) &&
                  classDate.isBefore(_currentWeekEnd.add(const Duration(days: 1)));
            } catch (e) {
              return false;
            }
          });

          if (!isInRange) continue;

          final subject = classData['name'] ?? "Unknown";
          final time = classData['time'] ?? "00:00";
          final room = classData['room'] ?? "N/A";
          final bool areTakingPlace = classData['areTakingPlace'] ?? true;
          final List<dynamic> students = classData['students'] ?? [];
          final List<dynamic> professors = classData['professor'] ?? [];

          final dayOfWeek = DateFormat('yyyy-MM-dd').parse(dates[0]).weekday - 1;

          if (userRole == "admin" ||
              (userRole == "prof" && professors.contains(userId)) ||
              (userRole == "student" && students.contains(userId))) {
            schedule[dayOfWeek]?.add({
              'subject': subject,
              'time': time,
              'room': room,
              'areTakingPlace': areTakingPlace,
              'docId': doc.id,
              'professorId': professors.isNotEmpty ? professors[0] : null,
            });
          }
        }
      });
    } catch (e) {
      print("🔥 Error loading classes: $e");
    }
  }

  void _selectWeek() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentWeekStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFFFA8742),
            colorScheme: ColorScheme.light(primary: Color(0xFFFA8742)),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _setWeekDates(picked);
    }
  }

  Widget _buildScheduleDay(int dayOfWeek) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayClasses = schedule[dayOfWeek] ?? [];

    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(days[dayOfWeek], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (dayClasses.isEmpty)
              const Text('No classes scheduled', style: TextStyle(fontSize: 16)),
            for (var classInfo in dayClasses)
              ListTile(
                title: Text(
                  "${classInfo['subject']} - ${classInfo['time']}",
                  style: TextStyle(fontWeight: FontWeight.bold, color: classInfo['areTakingPlace'] ? Colors.black : Colors.red),
                ),
                subtitle: Text("Room: ${classInfo['room']}\n${classInfo['areTakingPlace'] ? '✅ Taking place' : '❌ Canceled'}"),
                trailing: userRole == "admin"
                    ? IconButton(
                        icon: Icon(Icons.edit, color: Color(0xFFFA8742)),
                        onPressed: () => _editClassDetails(context, classInfo),
                      )
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _editClassDetails(BuildContext context, Map<String, dynamic> classInfo) async {
    TextEditingController timeController = TextEditingController(text: classInfo['time']);
    TextEditingController roomController = TextEditingController(text: classInfo['room']);
    bool classTakingPlace = classInfo['areTakingPlace'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Class Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: timeController, decoration: const InputDecoration(labelText: "Enter new time")),
            const SizedBox(height: 10),
            TextField(controller: roomController, decoration: const InputDecoration(labelText: "Enter new room")),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text("Class Taking Place?"),
              value: classTakingPlace,
              onChanged: (value) {
                setState(() {
                  classTakingPlace = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('classes').doc(classInfo['docId']).update({
                'time': timeController.text,
                'room': roomController.text,
                'areTakingPlace': classTakingPlace,
              });
              Navigator.pop(context);
              _loadClasses();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

@override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd MMM yyyy');
    final String startDateFormatted = dateFormat.format(_currentWeekStart);
    final String endDateFormatted = dateFormat.format(_currentWeekEnd);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Schedule'),
        backgroundColor: Color(0xFFFA8742),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _selectWeek,
                  child: const Text("Select Week"),
                ),
                Text(
                  "Week: $startDateFormatted - $endDateFormatted",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 7,
              itemBuilder: (context, index) => _buildScheduleDay(index),
            ),
          ),
        ],
      ),
    );
  }
}