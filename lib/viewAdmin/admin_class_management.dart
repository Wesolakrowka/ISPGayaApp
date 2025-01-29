import 'package:flutter/material.dart'; // Importing Flutter's material design library for building UI components
import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Cloud Firestore for database operations
import 'package:intl/intl.dart'; // Importing intl package for date formatting

// AdminClassManagement is a StatefulWidget that allows the admin to manage class schedules
class AdminClassManagement extends StatefulWidget {
  const AdminClassManagement({super.key}); // Constructor for AdminClassManagement

  @override
  _AdminClassManagementState createState() => _AdminClassManagementState(); // Creating the state for AdminClassManagement
}

// _AdminClassManagementState is the state class for AdminClassManagement
class _AdminClassManagementState extends State<AdminClassManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instance of Firestore to interact with the database

  String? _selectedCourse; // Variable to store the selected course
  String? _selectedProfessor; // Variable to store the selected professor
  List<String> _enrolledStudents = []; // List to store names of enrolled students
  String? _selectedDay; // Variable to store the selected day of the week
  final TextEditingController _timeController = TextEditingController(); // Controller for the class time input field
  final TextEditingController _roomController = TextEditingController(); // Controller for the room number input field
  DateTime? _startDate; // Variable to store the start date of the class
  DateTime? _endDate; // Variable to store the end date of the class

  // List of days of the week for selection
  final List<String> _daysOfWeek = [
    "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
  ];

  // Function to select a date range for the class
  void _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context, // Context for the date range picker
      firstDate: DateTime.now(), // The earliest date that can be selected
      lastDate: DateTime(2030), // The latest date that can be selected
      builder: (context, child) { // Customizing the theme of the date range picker
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFFFA8742), // Primary color for the theme
            colorScheme: const ColorScheme.light(primary: Color(0xFFFA8742)), // Color scheme for the theme
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary), // Button theme
          ),
          child: child!, // Returning the child widget
        );
      },
    );

    // If a date range was picked, update the state with the selected dates
    if (picked != null) {
      setState(() {
        _startDate = picked.start; // Set the start date
        _endDate = picked.end; // Set the end date
      });
    }
  }

  // Function to load course details based on the selected course ID
  void _loadCourseDetails(String courseId) async {
    var courseDoc = await _firestore.collection('courses').doc(courseId).get(); // Fetching the course document from Firestore
    if (courseDoc.exists) { // Check if the course document exists
      String professorId = courseDoc.data()?['id'] ?? ""; // Get the professor ID from the course document
      List<String> studentIds = List<String>.from(courseDoc.data()?['students'] ?? []); // Get the list of student IDs

      // Fetching the professor's name
      String professorName = "Unknown Professor"; // Default name if not found
      if (professorId.isNotEmpty) { // If a professor ID is available
        var professorDoc = await _firestore.collection('users').doc(professorId).get(); // Fetching the professor document
        professorName = (professorDoc.data() != null && professorDoc.data()!.containsKey('name'))
            ? professorDoc.data()!['name'] // Get the professor's name if it exists
            : "Unknown Professor"; // Default name if not found
      }

      // Fetching the names of enrolled students
      List<String> studentNames = []; // List to store student names
      for (String studentId in studentIds) { // Loop through each student ID
        var studentDoc = await _firestore.collection('users').doc(studentId).get(); // Fetching the student document
        if (studentDoc.exists && studentDoc.data() != null && studentDoc.data()!.containsKey('name')) {
          studentNames.add(studentDoc.data()!['name']); // Add the student's name to the list
        } else {
          studentNames.add("Unknown Student"); // Default name if not found
        }
      }

      // Update the state with the fetched professor and student names
      setState(() {
        _selectedProfessor = professorName;  // Set the selected professor's name
        _enrolledStudents = studentNames;   // Set the list of enrolled students' names
      });
    }
  }

  // Function to save the class schedule to Firestore
  void _saveSchedule() async {
    // Check if all required fields are filled
    if (_selectedCourse == null ||
        _selectedDay == null ||
        _startDate == null ||
        _endDate == null ||
        _timeController.text.isEmpty ||
        _roomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields"))); // Show a message if fields are empty
      return; // Exit the function if validation fails
    }

    // Add the class schedule to Firestore
    await _firestore.collection('classes').add({
      'courseId': _selectedCourse, // Store the selected course ID
      'professorId': _selectedProfessor, // Store the selected professor ID
      'students': _enrolledStudents, // Store the list of enrolled students
      'dayOfWeek': _selectedDay, // Store the selected day of the week
      'time': _timeController.text.trim(), // Store the class time
      'room': _roomController.text.trim(), // Store the room number
      'startDate': _startDate!.toIso8601String(), // Store the start date in ISO 8601 format
      'endDate': _endDate!.toIso8601String(), // Store the end date in ISO 8601 format
    });

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Schedule added successfully")));

    // Reset the form fields after saving
    setState(() {
      _selectedCourse = null; // Clear the selected course
      _selectedProfessor = null; // Clear the selected professor
      _enrolledStudents = []; // Clear the list of enrolled students
      _selectedDay = null; // Clear the selected day
      _timeController.clear(); // Clear the time input field
      _roomController.clear(); // Clear the room input field
      _startDate = null; // Clear the start date
      _endDate = null; // Clear the end date
    });
  }

  // Build method to create the UI for the AdminClassManagement screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin - Class Schedule"), backgroundColor: const Color(0xFFFA8742)), // AppBar with title and background color
      body: SingleChildScrollView( // Allows scrolling if content overflows
        padding: const EdgeInsets.all(16.0), // Padding around the content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start of the column
          children: [
            const Text("Select Course", style: TextStyle(fontWeight: FontWeight.bold)), // Label for course selection
            StreamBuilder<QuerySnapshot>( // StreamBuilder to listen for real-time updates from Firestore
              stream: _firestore.collection('courses').snapshots(), // Stream of course documents
              builder: (context, snapshot) { // Builder function to create UI based on snapshot data
                if (!snapshot.hasData) return const CircularProgressIndicator(); // Show loading indicator if no data
                var courses = snapshot.data!.docs; // Get the list of course documents
                return DropdownButton<String>( // Dropdown button for course selection
                  value: _selectedCourse, // Current selected course
                  isExpanded: true, // Expand to fill available space
                  items: courses.map((course) { // Map course documents to dropdown items
                    var data = course.data() as Map<String, dynamic>; // Get course data
                    return DropdownMenuItem(value: course.id, child: Text(data['name'])); // Create dropdown item
                  }).toList(),
                  onChanged: (value) { // Callback when a new course is selected
                    setState(() {
                      _selectedCourse = value; // Update the selected course
                    });
                    _loadCourseDetails(value!); // Load details for the selected course
                  },
                  hint: const Text("Select a course"), // Hint text for dropdown
                );
              },
            ),

            // If a course is selected, show additional information
            if (_selectedCourse != null) ...[
              const SizedBox(height: 10), // Space between elements
              const Text("Assigned Professor", style: TextStyle(fontWeight: FontWeight.bold)), // Label for assigned professor
              _selectedProfessor != null
                  ? Text("Professor: $_selectedProfessor", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)) // Show professor's name
                  : const Text("No professor assigned"), // Message if no professor is assigned

              const SizedBox(height: 10), // Space between elements
              const Text("Enrolled Students", style: TextStyle(fontWeight: FontWeight.bold)), // Label for enrolled students
              _enrolledStudents.isNotEmpty
                  ? Column(children: _enrolledStudents.map((s) => Text(s)).toList()) // Show list of enrolled students
                  : const Text("No students enrolled"), // Message if no students are enrolled
            ],

            const SizedBox(height: 10), // Space between elements
            const Text("Day of the Week", style: TextStyle(fontWeight: FontWeight.bold)), // Label for day selection
            DropdownButton<String>( // Dropdown button for selecting the day of the week
              value: _selectedDay, // Current selected day
              isExpanded: true, // Expand to fill available space
              items: _daysOfWeek.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(), // Map days to dropdown items
              onChanged: (value) => setState(() => _selectedDay = value), // Update selected day
              hint: const Text("Select a day"), // Hint text for dropdown
            ),

            const SizedBox(height: 10), // Space between elements
            const Text("Class Time", style: TextStyle(fontWeight: FontWeight.bold)), // Label for class time input
            TextField(controller: _timeController, decoration: const InputDecoration(hintText: "HH:MM")), // Input field for class time

            const SizedBox(height: 10), // Space between elements
            const Text("Room Number", style: TextStyle(fontWeight: FontWeight.bold)), // Label for room number input
            TextField(controller: _roomController, decoration: const InputDecoration(hintText: "Enter room number")), // Input field for room number

            const SizedBox(height: 10), // Space between elements
            const Text("Select Date Range", style: TextStyle(fontWeight: FontWeight.bold)), // Label for date range selection
            TextButton(
              onPressed: _selectDateRange, // Callback to select date range
              child: Text(_startDate == null || _endDate == null
                  ? "Select Date Range" // Display if no date range is selected
                  : "Selected: ${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}"), // Display selected date range
            ),

            const SizedBox(height: 20), // Space between elements
            Center(
              child: ElevatedButton(
                onPressed: _saveSchedule, // Callback to save the schedule
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFA8742), // Background color for the button
                  foregroundColor: Colors.white, // Text color for the button
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30), // Padding for the button
                ),
                child: const Text("Save Schedule"), // Button text
              ),
            ),
          ],
        ),
      ),
    );
  }
}
