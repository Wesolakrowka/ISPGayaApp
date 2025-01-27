import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminClassManagement extends StatefulWidget {
  const AdminClassManagement({super.key});

  @override
  _AdminClassManagementState createState() => _AdminClassManagementState();
}

class _AdminClassManagementState extends State<AdminClassManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _selectedCourse;
  String? _selectedProfessor;
  List<String> _enrolledStudents = [];
  String? _selectedDay;
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _daysOfWeek = [
    "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
  ];

  void _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFFFA8742),
            colorScheme: const ColorScheme.light(primary: Color(0xFFFA8742)),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _loadCourseDetails(String courseId) async {
  var courseDoc = await _firestore.collection('courses').doc(courseId).get();
  if (courseDoc.exists) {
    String professorId = courseDoc.data()?['id'] ?? "";
    List<String> studentIds = List<String>.from(courseDoc.data()?['students'] ?? []);

    // Pobieranie imienia profesora
    String professorName = "Unknown Professor";
    if (professorId.isNotEmpty) {
      var professorDoc = await _firestore.collection('users').doc(professorId).get();
      professorName = (professorDoc.data() != null && professorDoc.data()!.containsKey('name'))
          ? professorDoc.data()!['name']
          : "Unknown Professor";
    }

    // Pobieranie imion studentów
    List<String> studentNames = [];
    for (String studentId in studentIds) {
      var studentDoc = await _firestore.collection('users').doc(studentId).get();
      if (studentDoc.exists && studentDoc.data() != null && studentDoc.data()!.containsKey('name')) {
        studentNames.add(studentDoc.data()!['name']);
      } else {
        studentNames.add("Unknown Student");
      }
    }

    setState(() {
      _selectedProfessor = professorName;  // 🔥 Wyświetlamy imię profesora
      _enrolledStudents = studentNames;   // 🔥 Wyświetlamy listę studentów z imionami
    });
  }
}


  void _saveSchedule() async {
    if (_selectedCourse == null ||
        _selectedDay == null ||
        _startDate == null ||
        _endDate == null ||
        _timeController.text.isEmpty ||
        _roomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    await _firestore.collection('classes').add({
      'courseId': _selectedCourse,
      'professorId': _selectedProfessor, 
      'students': _enrolledStudents,
      'dayOfWeek': _selectedDay,
      'time': _timeController.text.trim(),
      'room': _roomController.text.trim(),
      'startDate': _startDate!.toIso8601String(),
      'endDate': _endDate!.toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Schedule added successfully")));

    setState(() {
      _selectedCourse = null;
      _selectedProfessor = null;
      _enrolledStudents = [];
      _selectedDay = null;
      _timeController.clear();
      _roomController.clear();
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin - Class Schedule"), backgroundColor: const Color(0xFFFA8742)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Course", style: TextStyle(fontWeight: FontWeight.bold)),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('courses').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                var courses = snapshot.data!.docs;
                return DropdownButton<String>(
                  value: _selectedCourse,
                  isExpanded: true,
                  items: courses.map((course) {
                    var data = course.data() as Map<String, dynamic>;
                    return DropdownMenuItem(value: course.id, child: Text(data['name']));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCourse = value;
                    });
                    _loadCourseDetails(value!);
                  },
                  hint: const Text("Select a course"),
                );
              },
            ),

            if (_selectedCourse != null) ...[
              const SizedBox(height: 10),
              const Text("Assigned Professor", style: TextStyle(fontWeight: FontWeight.bold)),
              _selectedProfessor != null
                  ? Text("Professor: $_selectedProfessor", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                  : const Text("No professor assigned"),

              const SizedBox(height: 10),
              const Text("Enrolled Students", style: TextStyle(fontWeight: FontWeight.bold)),
              _enrolledStudents.isNotEmpty
                  ? Column(children: _enrolledStudents.map((s) => Text(s)).toList())
                  : const Text("No students enrolled"),
            ],

            const SizedBox(height: 10),
            const Text("Day of the Week", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedDay,
              isExpanded: true,
              items: _daysOfWeek.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
              onChanged: (value) => setState(() => _selectedDay = value),
              hint: const Text("Select a day"),
            ),

            const SizedBox(height: 10),
            const Text("Class Time", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: _timeController, decoration: const InputDecoration(hintText: "HH:MM")),

            const SizedBox(height: 10),
            const Text("Room Number", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: _roomController, decoration: const InputDecoration(hintText: "Enter room number")),

            const SizedBox(height: 10),
            const Text("Select Date Range", style: TextStyle(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: _selectDateRange,
              child: Text(_startDate == null || _endDate == null
                  ? "Select Date Range"
                  : "Selected: ${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}"),
            ),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFA8742),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                ),
                child: const Text("Save Schedule"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
