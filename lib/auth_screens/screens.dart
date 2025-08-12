import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:card/card.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome Popup Style',
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  bool isLoginSelected = true;
  bool isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late final AnimationController _animController;
  late final Animation<double> _slideAnimation;

  static const double popupWidthMax = 400;
  static const double popupMinHeight = 480; // Tambah untuk phone field
  static const Color activeColor = Colors.black;
  static const Color inactiveTextColor = Colors.black87;

  String get baseUrl => dotenv.env['API_URL'] ?? 'http://localhost:3085';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    nameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void toggleSelection(bool loginSelected) {
    if (loginSelected != isLoginSelected) {
      setState(() {
        isLoginSelected = loginSelected;
        nameController.clear();
        usernameController.clear();
        phoneController.clear();
        passwordController.clear();

        if (isLoginSelected) {
          _animController.reverse();
        } else {
          _animController.forward();
        }
      });
    }
  }

  Future<Map<String, dynamic>> loginUser(String username, String password) async {
    final uri = Uri.parse('$baseUrl/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login gagal: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> registerUser(String name, String username, String password, String phone) async {
    final uri = Uri.parse('$baseUrl/register');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'username': username,
        'password': password,
        'phone': phone,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Registrasi gagal: ${response.body}');
    }
  }

  void onSubmit() async {
  if (!isLoginSelected) {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama lengkap harus diisi')),
      );
      return;
    }
    if (usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username harus diisi')),
      );
      return;
    }
    if (phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor telepon harus diisi')),
      );
      return;
    }
  } else {
    if (usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username harus diisi')),
      );
      return;
    }
  }

  if (passwordController.text.trim().isEmpty || passwordController.text.length < 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password minimal 6 karakter')),
    );
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    if (isLoginSelected) {
      final result = await loginUser(usernameController.text.trim(), passwordController.text.trim());
      print('Login sukses: $result');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login berhasil!')),
      );
      passwordController.clear();

      // Navigasi ke MyCard setelah login berhasil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyCard(apiUrl: baseUrl)),
      );

    } else {
      final result = await registerUser(
        nameController.text.trim(),
        usernameController.text.trim(),
        passwordController.text.trim(),
        phoneController.text.trim(),
      );
      print('Register sukses: $result');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
      );
      toggleSelection(true);
      passwordController.clear();
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


  Widget buildToggleButtons() {
    final double toggleWidth = (popupWidthMax - 48) / 2;
    return Container(
      width: popupWidthMax,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Align(
                alignment: Alignment(-1 + 2 * _slideAnimation.value, 0),
                child: Container(
                  width: toggleWidth,
                  height: 44,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
          Row(
            children: [
              SizedBox(
                width: toggleWidth,
                height: 44,
                child: TextButton(
                  onPressed: () => toggleSelection(true),
                  style: TextButton.styleFrom(
                    foregroundColor: isLoginSelected ? Colors.white : inactiveTextColor,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  child: const Text('Sign In'),
                ),
              ),
              SizedBox(
                width: toggleWidth,
                height: 44,
                child: TextButton(
                  onPressed: () => toggleSelection(false),
                  style: TextButton.styleFrom(
                    foregroundColor: !isLoginSelected ? Colors.white : inactiveTextColor,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  child: const Text('Sign Up'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildInputFields() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      child: Padding(
        key: ValueKey(isLoginSelected),
        padding: const EdgeInsets.only(top: 8),
        child: isLoginSelected
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      key: const ValueKey('username_login'),
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: "Username",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                  ),
                  TextField(
                    key: const ValueKey('password_login'),
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      key: const ValueKey('name_register'),
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Nama Lengkap",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      key: const ValueKey('username_register'),
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: "Username",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      key: const ValueKey('phone_register'),
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Nomor Telepon",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                  ),
                  TextField(
                    key: const ValueKey('password_register'),
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double popupWidth = screenWidth > popupWidthMax ? popupWidthMax : screenWidth - 40;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Container(
          width: popupWidth,
          constraints: BoxConstraints(
            minHeight: popupMinHeight,
            maxWidth: popupWidthMax,
          ),
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15,
                offset: Offset(0, 5),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Welcome",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Silakan masuk atau daftar untuk melanjutkan",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              buildToggleButtons(),
              const SizedBox(height: 24),
              buildInputFields(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isLoginSelected ? 'Login' : 'Register',
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
