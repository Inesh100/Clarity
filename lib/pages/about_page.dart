import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/common_navbar.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  // Opens the Flaticon link in browser
  Future<void> _launchURL() async {
    final Uri url = Uri.parse("https://www.flaticon.com/free-icons/flowers");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About & Credits"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 16),

            const Text(
              "Clarity App",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const Divider(height: 40, thickness: 1),

            const Text(
              "Developed by",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              "Nicholas Ramnarine",
              style: TextStyle(fontSize: 16),
            ),

            const Divider(height: 40, thickness: 1),

            const Text(
              "Credits & Attributions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: _launchURL,
              child: const Text(
                'Flowers icons created by Freepik - Flaticon',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "We appreciate the creators who make open design assets available to the community.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonNavBar(),
    );
  }
}
