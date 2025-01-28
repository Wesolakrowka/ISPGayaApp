import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _populateFirestore() async {
    await _populateCTeSP();
    await _populateMasters();
    print("✅ Firestore populated successfully!");
  }

  Future<void> _populateCTeSP() async {
    final CollectionReference ctespCollection = _firestore.collection('ctesp');

    Map<String, Map<String, String>> ctespData = {
      "accounting_financial_advisory": {
        "name": "Accounting and Financial Advisory",
        "description": "The globalization of business is becoming increasingly complex. Become a competent professional in accounting and financial advisory roles.",
        "details": "The Accounting and Financial Advisory Technician will support and collaborate in the accounting and financial department of public, private, and non-profit entities. These professionals are responsible for preparing and executing accounting and tax records, monitoring and controlling internal processes of current, administrative, and financial management, and providing relevant information to management or administration for decision-making. With an emphasis on professional practice, this course prepares professionals to face the challenges of the job market and achieve success in their careers."
      },
      "computer_networks_systems": {
        "name": "Computer Networks and Systems",
        "description": "Technology is changing the world by connecting millions of devices. Gain versatile expertise when learning, installing and configuring network infrastructures.",
        "details": "The ISPGAYA Higher Technician course in Computer Networks and Systems provides markedly practical and experimental training, based on the theoretical knowledge required for professional practice. Its aim is to train professionals in the field of information and communication technologies, with the skills required for professional practice in the field of IT, who must be able to direct projects, communicate clearly and effectively, work in multidisciplinary teams, adapt to changes and learn autonomously throughout life. These professionals will be qualified with broad and solid training that prepares them to direct and carry out all the tasks of the life cycle of networks and computer systems, oriented to the direct monitoring of their conception and design, development, production, quality, maintenance and administration. The graduates in Computer Networks and Systems develop their activities autonomously, capable of adapting to different professional challenges, applying their scientific knowledge and the methods and techniques specific to their specialty. This versatility makes them especially valid in organisations where an entrepreneurial spirit and permanent innovation are required, taking tasks of technical responsibility, contributing to the management of information and knowledge."
      },
      "digital_marketing": {
        "name": "Digital Marketing",
        "description": "Digital marketing is being at the forefront of organizations. Review performance indicators, manage social networks and create effective digital strategies.",
        "details": "The ISPGAYA Higher Technician course in Digital Marketing provides..."
      },
      "industrial_automation": {
        "name": "Electronics and Industrial Automation",
        "description": "Benefit from a world of opportunities in the field of electronics and automation. Develop skills in electrical installations and industrial automation systems.",
        "details": "The Higher Technician course in Electronics and Industrial Automation..."
      },
      "innovation_management": {
        "name": "Innovation Management in Technology and Creative Industries",
        "description": "It is important to be prepared for business development and optimize the application of technologies in the context of companies, brands and services.",
        "details": "The CTESP's mission is to create profiles that participate in the development..."
      },
      "machine_design": {
        "name": "Machine Design and Industrial Robotics",
        "description": "Industrial automation is growing. Become a technician in 3D modeling and design of industrial equipment based on robotic solutions",
        "details": "The CTESP's mission is to create profiles that participate in the development..."
      },
      "tourism_activities": {
        "name": "Management of Tourism Activities 4.0",
        "description": "Tourism 4.0 is innovation and the future. Make part of successful tourism professionals in an increasingly global society.",
        "details": "The CTESP's mission is to create profiles that participate in the development..."
      },
      "mechatronics_technology": {
        "name": "Mechatronics Technology",
        "description": "The constant development of Industry 4.0 means that mechatronics professionals have their hands quite full. Come build the world of intelligent systems.",
        "details": "The CTESP's mission is to create profiles that participate in the development..."
      },
      "qes_management": {
        "name": "Quality, Environment and Safety Management",
        "description": "Discover how to manage quality, environment and safety. Develop your strategic and leadership skills to create safe and sustainable environments.",
        "details": "The CTESP's mission is to create profiles that participate in the development..."
      },
      "sme_anagement": {
        "name": "SME Management",
        "description": "Transforming an idea into a business is within your reach. Discover the secrets of management and awaken your strategic, analytical thinking and leadership skills.",
        "details": "The CTESP's mission is to create profiles that participate in the development..."
      },
      "programming_information_systems": {
        "name": "Technologies and Programming of Information Systems ",
        "description": "Come take your first steps in the world of programming, discover the power of information systems and quickly become a versatile professional in the area.",
        "details": "The CTESP's mission is to create profiles that participate in the development..."
      },
      "tourism_management": {
        "name": "Tourism Management ",
        "description": "Contribute to the growth and positive impact of tourism. Help promote regions through tourist itineraries, event promotions and cultural animation.",
        "details": "The ISPGAYA Higher Technician in Tourism Management course provides markedly practical and experimental training, based on the theoretical knowledge required for professional practice, enabling companies in the region to incorporate new professionals, and the qualification of their employees, allowing them to adopt more professional, efficient and sustainable management.The Tourism Management Technician develops, promotes and markets diversified tourist products and services in the fields of leisure, culture, health, the environment and business. It performs duties in a public and private business environment, within the scope of collaboration, support and development of projects in the area of ​​interpretation and communication, namely in cultural heritage and health and wellness tourism, entertainment and cultural events, as well as in activities of internationalization of tourist products. This course is certified by Tourism of Portugal."
      },
    };

    for (var entry in ctespData.entries) {
      await ctespCollection.doc(entry.key).set(entry.value);
    }
    print("✅ CTeSP data added to Firestore!");
  }

   Future<void> _populateMasters() async {
    final CollectionReference mastersCollection = _firestore.collection('masters');

    Map<String, Map<String, String>> mastersData = {
      "cybersecurity": {
        "name": "Cybersecurity and Computer Systems Auditing",
        "description": "Cybersecurity is about information protection. Preventing, detecting and mitigating cyberattacks is essential for conscientious companies and and a modern society.",
        "details": "The Master in Cybersecurity and Computer Systems Auditing aims to address the growing challenges of computer security felt by companies, government entities and citizens, through advanced training of experts in network security and computer systems that can be integrated into multidisciplinary teams in the field of information and communication technologies. The Masters of this course will have acquired advanced technical knowledge in areas such as the prevention, detection and mitigation of cyber attacks, A Master in Cybersecurity and Auditing of Computer Systems aims to address the growing challenges of computer security felt by companies, government entities and citizens, through the advanced training of specialists in network and computer systems security that can be integrated into multidisciplinary teams in the area of ​​information and communication technologies. The Masters of this course will have acquired advanced technical knowledge in areas such as the prevention, detection and mitigation of cyberattacks, being able to manage complex processes of information security in organizations in different sectors of activity.This Master’s also aims to promote applied research in the areas of cybersecurity and auditing of computer systems, and foster a strong connection with the business world through projects, internships and seminars."
      }
    };

    for (var entry in mastersData.entries) {
      await mastersCollection.doc(entry.key).set(entry.value);
    }
    print("✅ Masters data added to Firestore!");
  }
}
