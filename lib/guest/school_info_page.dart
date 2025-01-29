import 'package:flutter/material.dart'; // Importing Flutter's material design library for building UI components
import 'package:url_launcher/url_launcher.dart'; // Importing the URL launcher package to open web URLs

class SchoolInfoPage extends StatelessWidget { // Defining a stateless widget for the school information page
  const SchoolInfoPage({super.key}); // Constructor for the SchoolInfoPage

  // Function to open URLs
  void _launchURL(String url) async { // Asynchronous function to launch a URL
    final Uri uri = Uri.parse(url); // Parsing the URL string into a Uri object
    if (await canLaunchUrl(uri)) { // Checking if the URL can be launched
      await launchUrl(uri); // Launching the URL if it can be opened
    } else {
      throw 'Could not launch $url'; // Throwing an error if the URL cannot be launched
    }
  }

  @override
  Widget build(BuildContext context) { // Building the UI for the SchoolInfoPage
    return Scaffold( // Scaffold provides a structure for the visual interface
      appBar: AppBar( // AppBar widget for the top app bar
        title: const Text("School Information"), // Title of the app bar
        backgroundColor: const Color(0xFFFA8742), // Background color of the app bar
      ),
      body: Stack( // Stack allows for overlapping widgets
        children: [
          // Background Image
          Positioned.fill( // Fills the available space with the background image
            child: Image.asset("assets/1-1440.jpg", fit: BoxFit.cover), // Background image for the page
          ),
          SafeArea( // Ensures that the content is not obscured by system UI
            child: SingleChildScrollView( // Allows scrolling of the content
              padding: const EdgeInsets.all(16.0), // Padding around the content
              child: Column( // Column arranges its children vertically
                crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start of the column
                children: [
                  // General Information
                  _buildSection( // Building a section for general information
                    title: "Instituto Superior Politécnico Gaya (ISPGAYA)", // Title of the section
                    content: "📍 Av. dos Descobrimentos, 333 \n4400-103 Santa Marinha - V.N. Gaia, Portugal", // Content of the section
                    isClickable: true, // Indicates that this section is clickable
                    url: "https://www.google.com/maps/search/?api=1&query=Av.+dos+Descobrimentos,+333+V.N.+Gaia+Portugal", // URL to open when clicked
                  ),
                  const SizedBox(height: 10), // Space between sections

                  // Contact Details
                  _buildSection( // Building a section for contact information
                    title: "Contact Information", // Title of the section
                    content: "📞 (+351) 223 745 730\n📧 info@ispgaya.pt", // Content of the section
                  ),
                  const SizedBox(height: 10), // Space between sections
                  _buildSection( // Building a section for the website
                    title: "Webside", // Title of the section
                    content: "ispgaya.pt/en", // Content of the section
                    isClickable: true, // Indicates that this section is clickable
                    url: "https://ispgaya.pt/en", // URL to open when clicked
                  ),
                  const SizedBox(height: 10), // Space between sections

                  // Opening Hours
                  _buildOpeningHours(), // Building the opening hours section
                  const SizedBox(height: 20), // Space between sections

                  // Transport Itineraries
                  _buildTransportInfo(), // Building the transport information section
                  const SizedBox(height: 20), // Space between sections

                  // Internal Contacts
                  _buildInternalContacts(), // Building the internal contacts section
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Styled Section Box (With Clickable Support)
  Widget _buildSection({required String title, required String content, bool isClickable = false, String? url}) { // Function to build a styled section
    return GestureDetector( // GestureDetector allows for detecting taps
      onTap: isClickable && url != null ? () => _launchURL(url) : null, // Launch URL if the section is clickable
      child: Container( // Container for styling the section
        padding: const EdgeInsets.all(12), // Padding inside the container
        decoration: BoxDecoration( // Decoration for the container
          color: Colors.white.withOpacity(0.85), // Background color with opacity
          borderRadius: BorderRadius.circular(10), // Rounded corners
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1)], // Shadow effect
        ),
        child: Column( // Column to arrange title and content vertically
          crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start of the column
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Title text with styling
            const SizedBox(height: 5), // Space between title and content
            Text( // Content text
              content,
              textAlign: TextAlign.justify, // Justified text alignment
              style: TextStyle(color: isClickable ? Colors.blue : Colors.black, decoration: isClickable ? TextDecoration.underline : TextDecoration.none), // Styling based on clickability
            ),
          ],
        ),
      ),
    );
  }

  // Opening Hours
  Widget _buildOpeningHours() { // Function to build the opening hours section
    return _buildSection( // Building a section for opening hours
      title: "Opening Hours", // Title of the section
      content: "📍 ISP GAYA\nMon-Fri: 09h00 - 23h00\nSat: 09h00 - 18h00\nSun: Closed\n\n" // Content of the section
          "📍 Secretary\nMon-Fri: 10h00 - 19h00\nSat & Sun: Closed", // Additional content for secretary hours
    );
  }

  // Transport Information
  Widget _buildTransportInfo() { // Function to build the transport information section
    return _buildSection( // Building a section for transport itineraries
      title: "Transport Itineraries", // Title of the section
      content: "🚍 Bus - STCP\n903 - Porto (Casa da Música) → Laborim (St.º Ovídio)\n907 - Laborim (St.º Ovídio) → Porto (Casa da Música)\n\n" // Content for bus routes
          "🚗 By Car\nHighway A1; IC1; A44; National Road 109; IC 23\nGPS: N41.119680, W8.623498", // Content for driving directions
    );
  }

  // Internal Contacts
  Widget _buildInternalContacts() { // Function to build the internal contacts section
    return _buildSection( // Building a section for internal contacts
      title: "Internal Contacts", // Title of the section
      content: "🏢 Offices\n" // Content for office contacts
          "• Social Action Office — bolsas@ispgaya.pt\n" // Contact for social action
          "• Office of Foreign Affairs — grext@ispgaya.pt\n" // Contact for foreign affairs
          "• Internship & Employment Office — estagios@ispgaya.pt\n" // Contact for internships and employment
          "• Psychological Support Office — gap@ispgaya.pt\n" // Contact for psychological support
          "• International Office — internationalaccess@ispgaya.pt\n" // Contact for international office
          "• Erasmus+ — erasmus@ispgaya.pt\n\n" // Contact for Erasmus+
          "🔬 Research Centers\n" // Content for research centers
          "• Research Centre — cid@ispgaya.pt\n" // Contact for research center
          "• IT Centre — ciisp@ispgaya.pt\n" // Contact for IT center
          "• Centre for Electronics & Metal Mechanics — cem@ispgaya.pt\n\n" // Contact for electronics and metal mechanics
          "📊 Others\n" // Content for other contacts
          "• Quality Observatory — obsqualidade@ispgaya.pt\n" // Contact for quality observatory
          "• ISPGAYA Editions — edisp@ispgaya.pt\n" // Contact for ISPGAYA editions
          "• Data Protection Officer — dpo@ispgaya.pt\n" // Contact for data protection officer
          "• Student Ombudsman — provedor@ispgaya.pt\n\n" // Contact for student ombudsman
          "🎓 Academic Services\n" // Content for academic services
          "• Secretary — secretaria@ispgaya.pt\n" // Contact for secretary
          "• Treasury — tesouraria@ispgaya.pt", // Contact for treasury
    );
  }
}
