import 'package:card/settings/favorite_page.dart';
import 'package:card/settings/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:card/settings/about.dart';
import 'package:card/card.dart';
import 'package:card/auth_screens/screens.dart';
import 'package:provider/provider.dart';
import 'package:card/providers/AppLanguage.dart';

class CustomHamburger extends StatelessWidget {
  final String? username;
  final String? phone;

  const CustomHamburger({
    Key? key,
    this.username,
    this.phone,
  }) : super(key: key);

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
                PopupMenuItem(
                  value: 'contacts',
                  child: Consumer<AppLanguage>(
                    builder: (context, lang, _) => Row(
                      children: [
                        const Icon(Icons.contacts, size: 20),
                        const SizedBox(width: 8),
                        Text(lang.getText('menu_contacts')),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'about',
                  child: Consumer<AppLanguage>(
                    builder: (context, lang, _) => Row(
                      children: [
                        const Icon(Icons.info_outline, size: 20),
                        const SizedBox(width: 8),
                        Text(lang.getText('menu_about')),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'settings',
                  child: Consumer<AppLanguage>(
                    builder: (context, lang, _) => Row(
                      children: [
                        const Icon(Icons.settings, size: 20),
                        const SizedBox(width: 8),
                        Text(lang.getText('menu_settings')),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'favorit',
                  child: Consumer<AppLanguage>(
                    builder: (context, lang, _) => Row(
                      children: [
                        const Icon(Icons.favorite, size: 20),
                        const SizedBox(width: 8),
                        Text(lang.getText('favorit')),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Consumer<AppLanguage>(
                    builder: (context, lang, _) => Row(
                      children: [
                        const Icon(Icons.logout, size: 20),
                        const SizedBox(width: 8),
                        Text(lang.getText('menu_logout')),
                      ],
                    ),
                  ),
                ),
              ],
            );

            if (selected == 'contacts') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyCard(
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MySetting(),
                ),
              );
            } else if (selected == 'favorit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FavoritPage(apiUrl: dotenv.env['API_URL'] ?? ''),
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
