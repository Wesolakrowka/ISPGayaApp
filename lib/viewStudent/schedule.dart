import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Firestore for database operations
import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase Auth for user authentication
import 'package:flutter/material.dart'; // Importing Flutter material package for UI components
import 'package:intl/intl.dart'; // Importing intl package for date formatting

// Schedule class is a StatefulWidget that manages the state of the schedule view
class Schedule extends StatefulWidget {
  const Schedule({super.key}); // Constructor for Schedule

  @override
  _ScheduleState createState() => _ScheduleState(); // Creating the state for Schedule
}

// _ScheduleState is the state class for Schedule
class _ScheduleState extends State<Schedule> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instance of Firestore to interact with the database
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance of FirebaseAuth to manage user authentication

  String userRole = ""; // Variable to store the user's role (e.g., student, professor, admin)
  String userId = ""; // Variable to store the user's ID
  List<String> enrolledCourses = []; // List to store the courses the user is enrolled in

  // Schedule map to hold classes for each day of the week
  Map<int, List<Map<String, dynamic>>> schedule = {
    0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: [], // Initializing the schedule for each day (0 = Monday, 6 = Sunday)
  };

  DateTime _currentWeekStart = DateTime.now(); // Variable to hold the start date of the current week
  DateTime _currentWeekEnd = DateTime.now().add(const Duration(days: 6)); // Variable to hold the end date of the current week

  @override
  void initState() {
    super.initState(); // Calling the superclass's initState
    _setWeekDates(DateTime.now()); // Setting the week dates to the current week
    _getUserData(); // Fetching user data
  }

  // Function to set the start and end dates of the week based on the provided date
  void _setWeekDates(DateTime date) {
    final int weekday = date.weekday; // Getting the current weekday (1 = Monday, 7 = Sunday)
    final DateTime startOfWeek = date.subtract(Duration(days: weekday - 1)); // Calculating the start of the week
    final DateTime endOfWeek = startOfWeek.add(const Duration(days: 6)); // Calculating the end of the week

    setState(() {
      _currentWeekStart = startOfWeek; // Updating the start of the week
      _currentWeekEnd = endOfWeek; // Updating the end of the week
    });

    _loadClasses(); // Loading classes for the current week
  }

  // Function to change the week by a specified direction (1 for next week, -1 for previous week)
  void _changeWeek(int direction) {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: 7 * direction)); // Updating the start of the week
      _currentWeekEnd = _currentWeekEnd.add(Duration(days: 7 * direction)); // Updating the end of the week
    });

    _loadClasses(); // Loading classes for the new week
  }

  // Function to fetch user data from Firestore
  Future<void> _getUserData() async {
    final user = _auth.currentUser; // Getting the current user
    if (user != null) { // Checking if the user is logged in
      userId = user.uid; // Storing the user's ID
      final userDoc = await _firestore.collection('users').doc(userId).get(); // Fetching user document from Firestore
      if (userDoc.exists) { // Checking if the user document exists
        setState(() {
          userRole = userDoc.data()?['role'] ?? ""; // Storing the user's role
          enrolledCourses = List<String>.from(userDoc.data()?['enrolledCourses'] ?? []); // Storing the enrolled courses
        });
        _loadClasses(); // Loading classes after fetching user data
      }
    }
  }

  // Function to load classes from Firestore
  Future<void> _loadClasses() async {
    try {
      QuerySnapshot classSnapshot = await _firestore.collection('classes').get(); // Fetching all classes from Firestore

      setState(() {
        schedule = {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []}; // Resetting the schedule for the week

        // Iterating through each class document
        for (var doc in classSnapshot.docs) {
          final Map<String, dynamic> classData = doc.data() as Map<String, dynamic>; // Getting class data

          final List<dynamic> students = classData['students'] ?? []; // Getting the list of students enrolled in the class
          final String? professorId = classData['professorId']; // Getting the professor's ID
          final String courseId = classData['courseId'] ?? ""; // Getting the course ID

          // Filtering classes based on user role
          if (userRole == "student" && !students.contains(userId)) continue; // Skip if the user is a student and not enrolled
          if (userRole == "prof" && professorId != userId) continue; // Skip if the user is a professor and not the class professor

          DateTime startDate = DateTime.parse(classData['startDate']); // Parsing the start date of the class
          DateTime endDate = DateTime.parse(classData['endDate']); // Parsing the end date of the class

          // Checking if the class is within the current week
          if (startDate.isAfter(_currentWeekEnd) || endDate.isBefore(_currentWeekStart)) continue;

          int dayOfWeek = _getDayOfWeekIndex(classData['dayOfWeek']); // Getting the index of the day of the week

          // Adding class information to the schedule
          schedule[dayOfWeek]?.add({
            'courseId': courseId, // Course ID
            'professorId': professorId, // Professor ID
            'time': classData['time'] ?? "00:00", // Class time
            'room': classData['room'] ?? "N/A", // Class room
            'areTakingPlace': classData['areTakingPlace'] ?? true, // Class status (taking place or canceled)
            'docId': doc.id, // Document ID of the class
          });
        }
      });
    } catch (e) {
      print("🔥 Error loading classes: $e"); // Logging any errors that occur while loading classes
    }
  }

  // Function to get the index of the day of the week
  int _getDayOfWeekIndex(String day) {
    final Map<String, int> days = {
      "Monday": 0, "Tuesday": 1, "Wednesday": 2, "Thursday": 3,
      "Friday": 4, "Saturday": 5, "Sunday": 6,
    };
    return days[day] ?? 0; // Returning the index of the day, defaulting to 0 (Monday) if not found
  }

  // Function to get the course name based on the course ID
  Future<String> _getCourseName(String courseId) async {
    if (courseId.isEmpty) return "Unknown Course"; // Returning default if course ID is empty
    var courseDoc = await _firestore.collection('courses').doc(courseId).get(); // Fetching course document
    var courseData = courseDoc.data(); // Getting course data
    return courseData != null ? courseData['name'] ?? "Unknown Course" : "Unknown Course"; // Returning course name or default
  }

  // Function to get the professor name based on the professor ID
  Future<String> _getProfessorName(String professorId) async {
    if (professorId.isEmpty) return "Unknown Professor"; // Returning default if professor ID is empty
    var professorDoc = await _firestore.collection('users').doc(professorId).get(); // Fetching professor document
    var professorData = professorDoc.data(); // Getting professor data
    return professorData != null ? professorData['name'] ?? "Unknown Professor" : "Unknown Professor"; // Returning professor name or default
  }

  // Function to build the schedule for a specific day of the week
  Widget _buildScheduleDay(int dayOfWeek) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']; // List of days
    final dayClasses = schedule[dayOfWeek] ?? []; // Getting classes for the specific day

    return Card(
      margin: const EdgeInsets.all(10), // Margin for the card
      child: Padding(
        padding: const EdgeInsets.all(10), // Padding inside the card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligning children to the start
          children: [
            Text(days[dayOfWeek], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), // Day title
            const SizedBox(height: 10), // Space between title and content
            if (dayClasses.isEmpty) // Checking if there are no classes scheduled
              const Text('No classes scheduled', style: TextStyle(fontSize: 16)), // Message for no classes
            for (var classInfo in dayClasses) // Iterating through each class for the day
              FutureBuilder(
                future: Future.wait([ // Fetching course and professor names concurrently
                  _getCourseName(classInfo['courseId']),
                  _getProfessorName(classInfo['professorId'] ?? ""),
                ]),
                builder: (context, AsyncSnapshot<List<String>> snapshot) {
                  if (!snapshot.hasData) { // Checking if data is still loading
                    return const ListTile(title: Text("Loading...")); // Loading indicator
                  }

                  String courseName = snapshot.data![0]; // Getting course name from snapshot
                  String professorName = snapshot.data![1]; // Getting professor name from snapshot

                  return ListTile(
                    title: Text(
                      "$courseName - ${classInfo['time']}", // Displaying course name and time
                      style: TextStyle(
                        fontWeight: FontWeight.bold, // Bold text for course name
                        color: classInfo['areTakingPlace'] ? Colors.black : Colors.red, // Color based on class status
                      ),
                    ),
                    subtitle: Text(
                      "Room: ${classInfo['room']}\nProfessor: $professorName\n${classInfo['areTakingPlace'] ? '✅ Taking place' : '❌ Canceled'}" // Displaying room, professor, and status
                    ),
                    trailing: userRole == "admin" ? IconButton( // Showing edit button if user is admin
                      icon: const Icon(Icons.edit, color: Color(0xFFFA8742)), // Edit icon
                      onPressed: () => _editClassDetails(context, classInfo), // Edit class details on press
                    ) : null, // No trailing widget if not admin
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // Function to edit class details
  Future<void> _editClassDetails(BuildContext context, Map<String, dynamic> classInfo) async {
    TextEditingController timeController = TextEditingController(text: classInfo['time']); // Controller for time input
    TextEditingController roomController = TextEditingController(text: classInfo['room']); // Controller for room input
    bool classTakingPlace = classInfo['areTakingPlace']; // Current status of the class

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Class Details"), // Dialog title
        content: Column(
          mainAxisSize: MainAxisSize.min, // Minimize the dialog size
          children: [
            TextField(controller: timeController, decoration: const InputDecoration(labelText: "Enter new time")), // Input for new time
            TextField(controller: roomController, decoration: const InputDecoration(labelText: "Enter new room")), // Input for new room
            SwitchListTile(
              title: const Text("Class Taking Place?"), // Switch for class status
              value: classTakingPlace, // Current value of the switch
              onChanged: (value) => setState(() => classTakingPlace = value), // Update state on change
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")), // Cancel button
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('classes').doc(classInfo['docId']).update({ // Updating class details in Firestore
                'time': timeController.text, // New time
                'room': roomController.text, // New room
                'areTakingPlace': classTakingPlace, // Updated status
              });
              Navigator.pop(context); // Close the dialog
              _loadClasses(); // Reload classes to reflect changes
            },
            child: const Text("Save"), // Save button
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String startWeekFormatted = DateFormat('dd MMM yyyy').format(_currentWeekStart); // Formatting start date
    String endWeekFormatted = DateFormat('dd MMM yyyy').format(_currentWeekEnd); // Formatting end date

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Schedule'), // Title of the app bar
        backgroundColor: const Color(0xFFFA8742), // Background color of the app bar
        actions: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _changeWeek(-1)), // Button to go to the previous week
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => _changeWeek(1)), // Button to go to the next week
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10), // Padding for the week label
            child: Text("Week: $startWeekFormatted - $endWeekFormatted", // Displaying the current week
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Styling the week label
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 7, // Number of days in the week
              itemBuilder: (context, index) => _buildScheduleDay(index), // Building schedule for each day
            ),
          ),
        ],
      ),
    );
  }
}
