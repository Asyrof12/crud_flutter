import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/AppLanguage.dart';
import '../menu_setting/keamanan.dart';
import 'hamburger.dart';

class MySetting extends StatefulWidget {
  const MySetting({super.key});

  @override
  State<MySetting> createState() => _MySettingState();
}

class _MySettingState extends State<MySetting> {
  String username = "";
  String phone = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? "Guest";
      phone = prefs.getString('phone') ?? "-";
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLang = Provider.of<AppLanguage>(context);

    return Scaffold(
      appBar: AppBar(
        leading: const CustomHamburger(),
        title: Text(appLang.getText('setting')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Menu Akun
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: Text(appLang.getText('account')),
              subtitle: Text(appLang.getText('account_info')),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(appLang.getText('account')),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Username: $username'),
                          const SizedBox(height: 8),
                          Text('Phone: $phone'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(appLang.getText('cancel')),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Menu Notifikasi
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.green),
              title: Text(appLang.getText('notification')),
              subtitle: Text(appLang.getText('notification')),
            ),
          ),

          // Menu Keamanan
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.security, color: Colors.orange),
              title: Text(appLang.getText('security')),
              subtitle: Text(appLang.getText('security')),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KeamananPage()),
                );
              },
            ),
          ),

          // Menu Bahasa
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.language, color: Colors.purple),
              title: Text(appLang.getText('language')),
              subtitle: Text(appLang.getText('language')),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    String selectedLanguage = appLang.currentLang;

                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: Text(appLang.getText('choose_language')),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RadioListTile(
                                title: const Text('Indonesia'),
                                value: 'id',
                                groupValue: selectedLanguage,
                                onChanged: (value) {
                                  setState(() {
                                    selectedLanguage = value!;
                                  });
                                },
                              ),
                              RadioListTile(
                                title: const Text('English'),
                                value: 'en',
                                groupValue: selectedLanguage,
                                onChanged: (value) {
                                  setState(() {
                                    selectedLanguage = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(appLang.getText('cancel')),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await appLang.changeLang(selectedLanguage);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        appLang.getText('language_changed')),
                                  ),
                                );
                              },
                              child: Text(appLang.getText('save')),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Menu Bantuan
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.help, color: Colors.red),
              title: Text(appLang.getText('help')),
              subtitle: Text(appLang.getText('help')),
            ),
          ),
        ],
      ),
    );
  }
}
