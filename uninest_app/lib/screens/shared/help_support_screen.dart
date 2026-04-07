import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  static const routeName = '/help-support';
  const HelpSupportScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    const email = 'jmaish819@gmail.com';
    const phone = '+254798533677';
    const whatsappUrl = 'https://wa.me/254798533677';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: const Color(0xFFF68B1E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Need help?\n\nUse one of the contact methods below and a support representative will contact you shortly.',
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            const Text('Email:', style: TextStyle(fontWeight: FontWeight.bold)),
            InkWell(
              onTap: () => _launchUrl('mailto:$email'),
              child: const Text(
                'jmaish819@gmail.com',
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Phone:', style: TextStyle(fontWeight: FontWeight.bold)),
            InkWell(
              onTap: () => _launchUrl('tel:$phone'),
              child: const Text(
                '+254 798 533 677',
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 16),
            const Text('WhatsApp:', style: TextStyle(fontWeight: FontWeight.bold)),
            InkWell(
              onTap: () => _launchUrl(whatsappUrl),
              child: const Text(
                '+254 798 533 677',
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'If WhatsApp fails to open, copy this number into your WhatsApp contacts manually.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
