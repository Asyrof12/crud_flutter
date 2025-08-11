import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyCard extends StatefulWidget {
  final String apiUrl;
  const MyCard({super.key, required this.apiUrl});

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  List data = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final url = "${widget.apiUrl}/list";
      print("🔍 Fetching from: $url");

      final response = await http.get(Uri.parse(url));

      print("📡 Status code: ${response.statusCode}");
      print("📦 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);

        if (parsed is List) {
          setState(() {
            data = parsed;
            isLoading = false;
            errorMessage = null;
          });
        } else if (parsed is Map && parsed['data'] is List) {
          setState(() {
            data = parsed['data'];
            isLoading = false;
            errorMessage = null;
          });
        } else {
          setState(() {
            errorMessage = "Data tidak dalam format list";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Gagal load data (${response.statusCode})";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Kontak")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(item['name'] ?? 'Tanpa Nama'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['phone'] ?? 'Tidak ada nomor'),
                            const SizedBox(height: 4),
                            Text(
                              "Created: ${item['created_at'] ?? '-'}",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        // trailing: Text("ID: ${item['id']}"),
                      ),
                    );
                  },
                ),
    );
  }
}
