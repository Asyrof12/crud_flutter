import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings/hamburger.dart';
import 'package:provider/provider.dart';
import '../providers/AppLanguage.dart';

class MyCard extends StatefulWidget {
  final String apiUrl;
  final String username;

  const MyCard({
    super.key,
    required this.apiUrl,
    required this.username,
  });

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  // Original data from API
  List data = [];
  // Data list to be displayed after filtering
  List _filteredData = [];
  bool isLoading = true;
  String? errorMessage;

  // Controller untuk input form tambah & edit kontak
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isAddingOrEditing = false;

  // Controller untuk search
  final TextEditingController _searchController = TextEditingController();

  bool _isSearching = false;

  String? savedUsername;
  int? savedId;
  String? savedPhone;

  @override
  void initState() {
    super.initState();
    _loadUser();
    fetchData();
    // Listener untuk memanggil fungsi filter setiap kali teks di search bar berubah
    _searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    // Penting untuk membersihkan controller saat widget tidak lagi digunakan
    _searchController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedUsername = prefs.getString('username') ?? 'User';
      savedId = prefs.getInt('id');
      savedPhone = prefs.getString('phone') ?? '';
    });
  }

  // Fungsi baru untuk melakukan filter pada data
  void _filterData() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredData = data.where((item) {
        final name = item['name']?.toString().toLowerCase() ?? '';
        final phone = item['phone']?.toString().toLowerCase() ?? '';
        // Cek apakah nama atau nomor telepon mengandung query
        return name.contains(query) || phone.contains(query);
      }).toList();
    });
  }

  Future<void> fetchData() async {
    final appLang = Provider.of<AppLanguage>(context, listen: false);
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id');

      if (userId == null) {
        setState(() {
          errorMessage = "User belum login!";
          isLoading = false;
        });
        return;
      }

      final url = "${widget.apiUrl}/list-all?saved_by=$userId";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        setState(() {
          data = parsed is List ? parsed : (parsed['data'] ?? []);
          // Setelah data didapat, langsung panggil filter
          _filterData();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              "${appLang.getText("failed_load")} (${response.statusCode})";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "${appLang.getText("error_msg")}: $e";
        isLoading = false;
      });
    }
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return '-';
    }
  }

  Future<void> addPhone() async {
    final appLang = Provider.of<AppLanguage>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLang.getText("name_phone_required"))),
      );
      return;
    }

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User belum login!")),
      );
      return;
    }

    setState(() {
      isAddingOrEditing = true;
    });

    try {
      final url = "${widget.apiUrl}/add-phone";
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'saved_by': userId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLang.getText("contact_added"))),
        );
        nameController.clear();
        phoneController.clear();
        Navigator.of(context).pop();
        fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "${appLang.getText("failed_add")} (${response.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${appLang.getText("error_msg")}: $e")),
      );
    } finally {
      setState(() {
        isAddingOrEditing = false;
      });
    }
  }

  Future<void> editPhone(String id) async {
    final appLang = Provider.of<AppLanguage>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLang.getText("name_phone_required"))),
      );
      return;
    }

    setState(() {
      isAddingOrEditing = true;
    });

    try {
      final url = "${widget.apiUrl}/edit";
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'name': name,
          'phone': phone,
          'saved_by': userId,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLang.getText("contact_updated"))),
        );
        fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "${appLang.getText("failed_edit")} (${response.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${appLang.getText("error_msg")}: $e")),
      );
    } finally {
      setState(() {
        isAddingOrEditing = false;
      });
    }
  }

  Future<void> deletePhone(int id) async {
    final appLang = Provider.of<AppLanguage>(context, listen: false);
    try {
      final response = await http.post(
        Uri.parse("${widget.apiUrl}/delete"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appLang.getText("contact_deleted")),
            backgroundColor: Colors.red,
          ),
        );
        await fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "${appLang.getText("failed_delete")} (${response.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${appLang.getText("error_msg")}: $e")),
      );
    }
  }

  void showAddContactModal() {
    final appLang = Provider.of<AppLanguage>(context, listen: false);
    final localNameController = TextEditingController();
    final localPhoneController = TextEditingController();
    final scaffoldContext = context;

    showDialog(
      context: scaffoldContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isAdding = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(appLang.getText("add_contact")),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: localNameController,
                      decoration: InputDecoration(
                        labelText: appLang.getText("name"),
                      ),
                    ),
                    TextField(
                      controller: localPhoneController,
                      decoration: InputDecoration(
                        labelText: appLang.getText("phone"),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isAdding ? null : () => Navigator.of(dialogContext).pop(),
                  child: Text(appLang.getText("cancel")),
                ),
                ElevatedButton(
                  onPressed: isAdding
                      ? null
                      : () async {
                          final name = localNameController.text.trim();
                          final phone = localPhoneController.text.trim();

                          if (name.isEmpty || phone.isEmpty) {
                            ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  appLang.getText("name_phone_required"),
                                ),
                              ),
                            );
                            return;
                          }

                          setState(() => isAdding = true);

                          try {
                            final prefs = await SharedPreferences.getInstance();
                            final userId = prefs.getInt('id');

                            final url = "${widget.apiUrl}/add-phone";
                            final response = await http.post(
                              Uri.parse(url),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode({
                                'name': name,
                                'phone': phone,
                                'saved_by': userId,
                              }),
                            );

                            if (response.statusCode == 200 ||
                                response.statusCode == 201) {
                              ScaffoldMessenger.of(scaffoldContext)
                                  .showSnackBar(
                                SnackBar(
                                  content:
                                      Text(appLang.getText("contact_added")),
                                ),
                              );
                              Navigator.of(dialogContext).pop();
                              fetchData();
                            } else {
                              ScaffoldMessenger.of(scaffoldContext)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "${appLang.getText("failed_add")} (${response.statusCode})",
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "${appLang.getText("error_msg")}: $e",
                                ),
                              ),
                            );
                          } finally {
                            setState(() => isAdding = false);
                          }
                        },
                  child: isAdding
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(appLang.getText("add")),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showEditContactModal(Map contact) {
    final appLang = Provider.of<AppLanguage>(context, listen: false);
    nameController.text = contact['name'] ?? '';
    phoneController.text = contact['phone'] ?? '';
    final idController =
        TextEditingController(text: contact['id']?.toString() ?? '');

    final rootContext = context;

    showDialog(
      context: rootContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(appLang.getText("edit_contact")),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration:
                      InputDecoration(labelText: appLang.getText("name")),
                ),
                TextField(
                  controller: phoneController,
                  decoration:
                      InputDecoration(labelText: appLang.getText("phone")),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isAddingOrEditing
                  ? null
                  : () {
                      Navigator.of(dialogContext).pop();
                      nameController.clear();
                      phoneController.clear();
                    },
              child: Text(appLang.getText("cancel")),
            ),
            ElevatedButton(
              onPressed: isAddingOrEditing
                  ? null
                  : () async {
                      Navigator.of(dialogContext).pop();
                      await editPhone(idController.text);
                      // Hapus snackbar yang tidak perlu di sini
                      // karena sudah ada di dalam fungsi editPhone
                    },
              child: isAddingOrEditing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(appLang.getText("save")),
            ),
          ],
        );
      },
    );
  }

  void showDeleteConfirmDialog(Map contact) {
    final appLang = Provider.of<AppLanguage>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appLang.getText("confirm_delete")),
        content: Text(
            '${appLang.getText("delete_contact_q")} "${contact['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(appLang.getText("cancel")),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await deletePhone(int.parse(contact['id'].toString()));
            },
            child: Text(appLang.getText("delete")),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLang = Provider.of<AppLanguage>(context);

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: false,
            titleSpacing: 0,
            title: Row(
              children: [
                CustomHamburger(username: savedUsername ?? widget.username),
                const SizedBox(width: 10),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text:
                            "${appLang.getText("welcome")}, ${savedUsername ?? widget.username}",
                      ),
                      if (savedPhone != null)
                        TextSpan(
                          text: " $savedPhone",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : ListView(
                    children: [
                      // 🔹 HEADER (akan ikut scroll ke atas)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                appLang.getText("contact_list"),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              width: _isSearching ? 240 : 44,
                              height: 40,
                              child: _isSearching
                                  ? TextField(
                                      controller: _searchController,
                                      autofocus: true,
                                      textInputAction: TextInputAction.search,
                                      onChanged: (_) => _filterData(),
                                      decoration: InputDecoration(
                                        hintText: appLang.getText('Pencarian'),
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            setState(() {
                                              _isSearching = false;
                                              _searchController.clear();
                                              _filteredData = data;
                                            });
                                          },
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.search),
                                      onPressed: () {
                                        setState(() {
                                          _isSearching = true;
                                        });
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),

                      // 🔹 LIST KONTAK
                      ..._filteredData.map((item) {
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: ListTile(
                            title: Text(
                                item['name'] ?? appLang.getText("no_name")),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['phone'] ??
                                    appLang.getText("no_phone_number")),
                                const SizedBox(height: 4),
                                Text(
                                  "${appLang.getText("created_at")}: ${formatDate(item['created_at'])}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => showEditContactModal(item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      showDeleteConfirmDialog(item),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 33), // geser ke atas 30px
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 45,
                height: 45,
                child: FloatingActionButton(
                  heroTag: "refreshBtn",
                  onPressed: isLoading ? null : fetchData,
                  backgroundColor: Colors.blue,
                  child: isLoading
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.refresh, size: 20),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 45,
                height: 45,
                child: FloatingActionButton(
                  heroTag: "addBtn",
                  onPressed: showAddContactModal,
                  child: const Icon(Icons.add, size: 20),
                ),
              ),
            ],
          ),
        ));
  }
}
