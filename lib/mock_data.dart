import 'package:cloud_firestore/cloud_firestore.dart';

void uploadDegreesToFirestore() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Lista kierunków
  List<Map<String, String>> degrees = [
    {
      "name": "Accounting",
      "description": "The Accounting course at ISPGAYA provides practical training with a strong theoretical foundation, preparing students for financial and business challenges."
    },
    {
      "name": "Computer Engineering",
      "description": "A computer engineer can create something from an idea, connect everything, and work anywhere in the world."
    },
    {
      "name": "Electronic & Automation Engineering",
      "description": "Automation is in our DNA. Revolutionize industry with electronics and automation engineering."
    },
    {
      "name": "Management",
      "description": "Being a great manager means anticipating daily challenges and making strategic decisions for success."
    },
    {
      "name": "Mechanical Engineering",
      "description": "Mechanical engineers design and develop innovative systems, from simple screws to complex satellites."
    },
    {
      "name": "Tourism and Sustainable Business",
      "description": "Be part of the change in tourism by promoting sustainable and profitable tourism experiences."
    }
  ];

  // Zapisywanie do Firestore
  for (var degree in degrees) {
    await firestore.collection('degrees').doc(degree["name"]).set({
      "name": degree["name"],
      "description": degree["description"],
    });
    print("✅ Added: ${degree['name']}");
  }

  print("🔥 All degrees uploaded successfully!");
}
