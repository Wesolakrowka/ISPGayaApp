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

  void _changeWeek(int direction) {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: 7 * direction));
      _currentWeekEnd = _currentWeekEnd.add(Duration(days: 7 * direction));
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
      QuerySnapshot classSnapshot = await _firestore.collection('classes').get();

      setState(() {
        schedule = {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []};

        for (var doc in classSnapshot.docs) {
          final Map<String, dynamic> classData = doc.data() as Map<String, dynamic>;

          final List<dynamic> students = classData['students'] ?? [];
          final String? professorId = classData['professorId'];
          final String courseId = classData['courseId'] ?? "";

          if (userRole == "student" && !students.contains(userId)) continue;
          if (userRole == "prof" && professorId != userId) continue;

          DateTime startDate = DateTime.parse(classData['startDate']);
          DateTime endDate = DateTime.parse(classData['endDate']);

          if (startDate.isAfter(_currentWeekEnd) || endDate.isBefore(_currentWeekStart)) continue;

          int dayOfWeek = _getDayOfWeekIndex(classData['dayOfWeek']);

          schedule[dayOfWeek]?.add({
            'courseId': courseId,
            'professorId': professorId,
            'time': classData['time'] ?? "00:00",
            'room': classData['room'] ?? "N/A",
            'areTakingPlace': classData['areTakingPlace'] ?? true,
            'docId': doc.id,
          });
        }
      });
    } catch (e) {
      print("🔥 Error loading classes: $e");
    }
  }

  int _getDayOfWeekIndex(String day) {
    final Map<String, int> days = {
      "Monday": 0, "Tuesday": 1, "Wednesday": 2, "Thursday": 3,
      "Friday": 4, "Saturday": 5, "Sunday": 6,
    };
    return days[day] ?? 0;
  }

  Future<String> _getCourseName(String courseId) async {
    if (courseId.isEmpty) return "Unknown Course";
    var courseDoc = await _firestore.collection('courses').doc(courseId).get();
    var courseData = courseDoc.data();
    return courseData != null ? courseData['name'] ?? "Unknown Course" : "Unknown Course";
  }

  Future<String> _getProfessorName(String professorId) async {
    if (professorId.isEmpty) return "Unknown Professor";
    var professorDoc = await _firestore.collection('users').doc(professorId).get();
    var professorData = professorDoc.data();
    return professorData != null ? professorData['name'] ?? "Unknown Professor" : "Unknown Professor";
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
              FutureBuilder(
                future: Future.wait([
                  _getCourseName(classInfo['courseId']),
                  _getProfessorName(classInfo['professorId'] ?? ""),
                ]),
                builder: (context, AsyncSnapshot<List<String>> snapshot) {
                  if (!snapshot.hasData) {
                    return const ListTile(title: Text("Loading..."));
                  }

                  String courseName = snapshot.data![0];
                  String professorName = snapshot.data![1];

                  return ListTile(
                    title: Text(
                      "$courseName - ${classInfo['time']}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: classInfo['areTakingPlace'] ? Colors.black : Colors.red,
                      ),
                    ),
                    subtitle: Text(
                      "Room: ${classInfo['room']}\nProfessor: $professorName\n${classInfo['areTakingPlace'] ? '✅ Taking place' : '❌ Canceled'}"
                    ),
                    trailing: userRole == "admin" ? IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFFFA8742)),
                      onPressed: () => _editClassDetails(context, classInfo),
                    ) : null,
                  );
                },
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
            TextField(controller: roomController, decoration: const InputDecoration(labelText: "Enter new room")),
            SwitchListTile(
              title: const Text("Class Taking Place?"),
              value: classTakingPlace,
              onChanged: (value) => setState(() => classTakingPlace = value),
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
    String startWeekFormatted = DateFormat('dd MMM yyyy').format(_currentWeekStart);
    String endWeekFormatted = DateFormat('dd MMM yyyy').format(_currentWeekEnd);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Schedule'),
        backgroundColor: const Color(0xFFFA8742),
        actions: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _changeWeek(-1)),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => _changeWeek(1)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text("Week: $startWeekFormatted - $endWeekFormatted",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
