import 'package:card/settings/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:card/settings/about.dart';
import 'package:card/card.dart';
import 'package:card/auth_screens/screens.dart';

class CustomHamburger extends StatelessWidget {
  final String? username;
  const CustomHamburger({
    Key? key,
    this.username,
    }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () async {
            final RenderBox button = context.findRenderObject() as RenderBox;
            final RenderBox overlay =
                Overlay.of(context).context.findRenderObject() as RenderBox;

            final RelativeRect position = RelativeRect.fromRect(
              Rect.fromPoints(
                button.localToGlobal(Offset.zero, ancestor: overlay),
                button.localToGlobal(button.size.bottomRight(Offset.zero),
                    ancestor: overlay),
              ),
              Offset.zero & overlay.size,
            );

            final selected = await showMenu<String>(
              context: context,
              position: position,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              items: [
                const PopupMenuItem(
                  value: 'contacts',
                  child: Row(
                    children: [
                      Icon(Icons.contacts, size: 20),
                      SizedBox(width: 8),
                      Text('Daftar Kontak'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'about',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20),
                      SizedBox(width: 8),
                      Text('About Aplikasi'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, size: 20),
                      SizedBox(width: 8),
                      Text('Setting'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            );

            if (selected == 'contacts') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyCard(
                    // username: username ?? '',
                    username: username ?? '',
                    apiUrl: dotenv.env['API_URL'] ?? '',
                  ),
                ),
              );
            } else if (selected == 'about') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutPage(),
                ),
              );
            } else if (selected == 'settings') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MySetting(),
                ),
              );
            } else if (selected == 'logout') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginApp(),
                ),
              );
            }
          },
        );
      },
    );
  }
}
