import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:card/providers/AppLanguage.dart';

class KeamananPage extends StatelessWidget {
  const KeamananPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appLang = Provider.of<AppLanguage>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(appLang.getText("security_settings")),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.lock, color: Colors.blue),
              title: Text(appLang.getText("change_password")),
              subtitle: Text(appLang.getText("change_password_sub")),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    final oldPasswordController = TextEditingController();
                    final newPasswordController = TextEditingController();
                    final confirmPasswordController = TextEditingController();

                    return AlertDialog(
                      title: Text(appLang.getText("change_password")),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextField(
                              controller: oldPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: appLang.getText("old_password"),
                              ),
                            ),
                            TextField(
                              controller: newPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: appLang.getText("new_password"),
                              ),
                            ),
                            TextField(
                              controller: confirmPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText:
                                    appLang.getText("confirm_new_password"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(appLang.getText("cancel")),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (newPasswordController.text !=
                                confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    appLang.getText("password_not_match"),
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    appLang.getText("password_changed"),
                                  ),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                          child: Text(appLang.getText("change")),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.fingerprint, color: Colors.green),
              title: Text(appLang.getText("biometric_auth")),
              subtitle: Text(appLang.getText("biometric_auth_sub")),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(appLang.getText("biometric_auth")),
                    content: Text(appLang.getText("biometric_auth_confirm")),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(appLang.getText("cancel")),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                appLang.getText("biometric_enabled"),
                              ),
                            ),
                          );
                        },
                        child: Text(appLang.getText("yes")),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.security, color: Colors.orange),
              title: Text(appLang.getText("account_security")),
              subtitle: Text(appLang.getText("account_security_sub")),
              onTap: () {},
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.privacy_tip, color: Colors.purple),
              title: Text(appLang.getText("privacy")),
              subtitle: Text(appLang.getText("privacy_sub")),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
