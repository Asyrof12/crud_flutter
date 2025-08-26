import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:card/settings/hamburger.dart';
import '../providers/AppLanguage.dart';
import 'package:card/utils/lang.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  Map<String, String> aboutData = {};
  bool isLoading = true;

  Future<void> fetchAbout() async {
    final baseUrl = dotenv.env['API_URL'] ?? '';
    final response = await http.get(Uri.parse("$baseUrl/app-settings"));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      Map<String, String> mapped = {
        for (var item in data) item['name']: item['value']
      };

      setState(() {
        aboutData = mapped;
        isLoading = false;
      });
    } else {
      throw Exception("Gagal ambil data About");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAbout();
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);
    final lang = Lang.texts[appLanguage.currentLang]!;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const CustomHamburger(),
        title: Text(lang['about']!),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title: Text(lang['app_name'] ?? "Nama Aplikasi"),
              subtitle: Text(aboutData["app_name"] ?? "-"),
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.description, color: Colors.purple),
              title: Text(lang['description'] ?? "Deskripsi"),
              subtitle: Text(aboutData["description"] ?? "-"),
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.verified, color: Colors.green),
              title: Text(lang['version'] ?? "Versi"),
              subtitle: Text(aboutData["versi"] ?? "-"),
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.orange),
              title: Text(lang['developer'] ?? "Developer"),
              subtitle: Text(
                // kalau ada lebih dari 1 developer
                "${aboutData["developer1"] ?? ""} ${aboutData["developer2"] ?? ""}",
              ),
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.email, color: Colors.red),
              title: Text(lang['kontak'] ?? "Kontak"),
              subtitle: Text(aboutData["kontak"] ?? "-"),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              '© 2025 Magang DMC. All rights reserved.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
