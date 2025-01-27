import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SchoolInfoPage extends StatelessWidget {
  const SchoolInfoPage({super.key});

  // 📌 Function to open URLs
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("School Information"),
        backgroundColor: const Color(0xFFFA8742),
      ),
      body: Stack(
        children: [
          // 📷 Background Image
          Positioned.fill(
            child: Image.asset("assets/1-1440.jpg", fit: BoxFit.cover),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🏫 General Information
                  _buildSection(
                    title: "Instituto Superior Politécnico Gaya (ISPGAYA)",
                    content: "📍 Av. dos Descobrimentos, 333 \n4400-103 Santa Marinha - V.N. Gaia, Portugal",
                    isClickable: true,
                    url: "https://www.google.com/maps/search/?api=1&query=Av.+dos+Descobrimentos,+333+V.N.+Gaia+Portugal",
                  ),
                  const SizedBox(height: 10),

                  // 📌 Contact Details
                  _buildSection(
                    title: "Contact Information",
                    content: "📞 (+351) 223 745 730\n📧 info@ispgaya.pt",
                  ),
                  const SizedBox(height: 10),
                   _buildSection(
                    title: "Webside",
                    content: "ispgaya.pt/en",
                    isClickable: true,
                    url: "https://ispgaya.pt/en",
                  ),
                  const SizedBox(height: 10),

                  // 🕒 Opening Hours
                  _buildOpeningHours(),
                  const SizedBox(height: 20),

                  // 🚌 Transport Itineraries
                  _buildTransportInfo(),
                  const SizedBox(height: 20),

                  // 🏢 Internal Contacts
                  _buildInternalContacts(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📌 Styled Section Box (With Clickable Support)
  Widget _buildSection({required String title, required String content, bool isClickable = false, String? url}) {
    return GestureDetector(
      onTap: isClickable && url != null ? () => _launchURL(url) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(
              content,
              textAlign: TextAlign.justify,
              style: TextStyle(color: isClickable ? Colors.blue : Colors.black, decoration: isClickable ? TextDecoration.underline : TextDecoration.none),
            ),
          ],
        ),
      ),
    );
  }

  // 🕒 Opening Hours
  Widget _buildOpeningHours() {
    return _buildSection(
      title: "Opening Hours",
      content: "📍 ISP GAYA\nMon-Fri: 09h00 - 23h00\nSat: 09h00 - 18h00\nSun: Closed\n\n"
          "📍 Secretary\nMon-Fri: 10h00 - 19h00\nSat & Sun: Closed",
    );
  }

  // 🚍 Transport Information
  Widget _buildTransportInfo() {
    return _buildSection(
      title: "Transport Itineraries",
      content: "🚍 Bus - STCP\n903 - Porto (Casa da Música) → Laborim (St.º Ovídio)\n907 - Laborim (St.º Ovídio) → Porto (Casa da Música)\n\n"
          "🚗 By Car\nHighway A1; IC1; A44; National Road 109; IC 23\nGPS: N41.119680, W8.623498",
    );
  }

  // 📌 Internal Contacts
  Widget _buildInternalContacts() {
    return _buildSection(
      title: "Internal Contacts",
      content: "🏢 Offices\n"
          "• Social Action Office — bolsas@ispgaya.pt\n"
          "• Office of Foreign Affairs — grext@ispgaya.pt\n"
          "• Internship & Employment Office — estagios@ispgaya.pt\n"
          "• Psychological Support Office — gap@ispgaya.pt\n"
          "• International Office — internationalaccess@ispgaya.pt\n"
          "• Erasmus+ — erasmus@ispgaya.pt\n\n"
          "🔬 Research Centers\n"
          "• Research Centre — cid@ispgaya.pt\n"
          "• IT Centre — ciisp@ispgaya.pt\n"
          "• Centre for Electronics & Metal Mechanics — cem@ispgaya.pt\n\n"
          "📊 Others\n"
          "• Quality Observatory — obsqualidade@ispgaya.pt\n"
          "• ISPGAYA Editions — edisp@ispgaya.pt\n"
          "• Data Protection Officer — dpo@ispgaya.pt\n"
          "• Student Ombudsman — provedor@ispgaya.pt\n\n"
          "🎓 Academic Services\n"
          "• Secretary — secretaria@ispgaya.pt\n"
          "• Treasury — tesouraria@ispgaya.pt",
    );
  }
}
