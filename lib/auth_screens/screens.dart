import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:card/card.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  bool isLoginSelected = true;
  bool isLoading = false;

  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;

  final _formKeyLogin = GlobalKey<FormState>();
  final _formKeyRegister = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late final AnimationController _animController;
  late final Animation<double> _slideAnimation;

  static const double popupWidthMax = 400;
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

  // ---- API CALLS ----
  Future<Map<String, dynamic>> _login(String username, String password) async {
    final uri = Uri.parse('$baseUrl/login');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (res.statusCode != 200) {
      throw Exception(_extractError(res.body, 'Login gagal'));
    }

    final data = _safeJson(res.body);

    // Jika login berhasil, lewati exception
    if (!(data['success'] == true ||
        (data['message']?.toLowerCase().contains('berhasil') ?? false))) {
      throw Exception(data['message'] ?? 'Kredensial salah');
    }

    return data;
  }

  Future<Map<String, dynamic>> _register({
    required String name,
    required String username,
    required String password,
    required String phone,
  }) async {
    final uri = Uri.parse('$baseUrl/register');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'username': username,
        'password': password,
        'phone': phone,
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(_extractError(res.body, 'Registrasi gagal'));
    }

    final data = _safeJson(res.body);
    if (!(data['success'] == true ||
        (data['message']?.toLowerCase().contains('berhasil') ?? false))) {
      throw Exception(data['message'] ?? 'Registrasi gagal');
    }

    return data;
  }

  Map<String, dynamic> _safeJson(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'message': 'Format response tidak valid'};
    } catch (_) {
      return {'message': 'Response bukan JSON'};
    }
  }

  String _extractError(String body, String fallback) {
    try {
      final d = jsonDecode(body);
      if (d is Map && d['message'] is String) return d['message'];
    } catch (_) {}
    return fallback;
  }

  // ---- SUBMIT ----
  Future<void> onSubmit() async {
    FocusScope.of(context).unfocus();

    if (isLoginSelected) {
      if (!(_formKeyLogin.currentState?.validate() ?? false)) return;
    } else {
      if (!(_formKeyRegister.currentState?.validate() ?? false)) return;
    }

    setState(() => isLoading = true);

    try {
      if (isLoginSelected) {
        final data = await _login(
          usernameController.text.trim(),
          passwordController.text.trim(),
        );

        // ✅ simpan username ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('username', data['username']);
        await prefs.setInt('id', data['id']);
        await prefs.setString('phone', data['phone']);

        // (opsional) kalau API juga ngasih token, bisa disimpan
        // await prefs.setString('token', data['token']);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyCard(
              apiUrl: dotenv.env['API_URL'] ?? '',
              username: data['username'], // ambil dari response login
              // ambil phone dari response, fallback '' kalau null
            ),
          ),
        );
      } else {
        final data = await _register(
          name: nameController.text.trim(),
          username: usernameController.text.trim(),
          password: passwordController.text.trim(),
          phone: phoneController.text.trim(),
        );

        _showSnack(data['message'] ?? 'Registrasi berhasil! Silakan login.');
        toggleSelection(true);
        passwordController.clear();
      }
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ---- UI ----
  Widget buildToggleButtons() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double containerWidth =
        screenWidth > popupWidthMax ? popupWidthMax : screenWidth - 40;
    final double toggleWidth =
        containerWidth * 0.43; // ✅ lebih kecil dari setengah

    return Container(
      width: containerWidth,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
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
                  height: 36, // sedikit lebih kecil dari container tinggi
                  margin: const EdgeInsets.symmetric(
                      horizontal: 4), // kasih jarak ke tepi
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: isLoading ? null : () => toggleSelection(true),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        isLoginSelected ? Colors.white : inactiveTextColor,
                    backgroundColor: Colors.transparent,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Sign In',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: isLoading ? null : () => toggleSelection(false),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        !isLoginSelected ? Colors.white : inactiveTextColor,
                    backgroundColor: Colors.transparent,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Sign Up',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildLoginForm() {
    return Form(
      key: _formKeyLogin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextFormField(
              key: const ValueKey('username_login'),
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Username harus diisi'
                  : null,
            ),
          ),
          TextFormField(
            key: const ValueKey('password_login'),
            controller: passwordController,
            obscureText: _obscureLoginPassword,
            decoration: InputDecoration(
              labelText: "Password",
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureLoginPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureLoginPassword = !_obscureLoginPassword; // toggle
                  });
                },
              ),
            ),
            validator: (v) => (v == null || v.length < 6)
                ? 'Password minimal 6 karakter'
                : null,
          ),
        ],
      ),
    );
  }

  Widget buildRegisterForm() {
    return Form(
      key: _formKeyRegister,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextFormField(
              key: const ValueKey('name_register'),
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nama Lengkap",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Nama lengkap harus diisi'
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextFormField(
              key: const ValueKey('username_register'),
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Username harus diisi'
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextFormField(
              key: const ValueKey('phone_register'),
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Nomor Telepon",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Nomor telepon harus diisi'
                  : null,
            ),
          ),
          TextFormField(
            key: const ValueKey('password_register'),
            controller: passwordController,
            obscureText: _obscureRegisterPassword,
            decoration: InputDecoration(
              labelText: "Password",
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureRegisterPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureRegisterPassword =
                        !_obscureRegisterPassword; // toggle
                  });
                },
              ),
            ),
            validator: (v) => (v == null || v.length < 6)
                ? 'Password minimal 6 karakter'
                : null,
          ),
        ],
      ),
    );
  }

  Widget buildInputFields() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Padding(
        key: ValueKey(isLoginSelected),
        padding: const EdgeInsets.only(top: 8),
        child: isLoginSelected ? buildLoginForm() : buildRegisterForm(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double popupWidth =
        screenWidth > popupWidthMax ? popupWidthMax : screenWidth - 40;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Container(
              width: popupWidth,
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
                  AnimatedSize(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    child: buildInputFields(),
                  ),
                  const SizedBox(height: 16),
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
        ),
      ),
    );
  }
}
