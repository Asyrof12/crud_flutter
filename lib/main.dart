import 'package:card/auth_screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart'; // tambahkan provider
import 'providers/AppLanguage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Load file .env
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppLanguage(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiUrl = dotenv.env['API_URL'] ?? '';
    print("✅ API_URL dari .env: $apiUrl");

    final appLang = Provider.of<AppLanguage>(context); // ambil bahasa

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daftar Kontak',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginApp(),
      locale: Locale(appLang.currentLang), // bahasa ikut pilihan user
    );
  }
}
