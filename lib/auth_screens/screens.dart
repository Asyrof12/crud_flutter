import 'package:flutter/material.dart';

void main() {
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

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late final AnimationController _animController;
  late final Animation<double> _slideAnimation;

  static const double popupWidthMax = 400;
  static const double popupMinHeight = 430;

  static const Color activeColor = Colors.black;
  static const Color inactiveTextColor = Colors.black87;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void toggleSelection(bool loginSelected) {
    if (loginSelected != isLoginSelected) {
      setState(() {
        isLoginSelected = loginSelected;
        nameController.clear();
        emailController.clear();
        passwordController.clear();

        if (isLoginSelected) {
          _animController.reverse();
        } else {
          _animController.forward();
        }
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
                      key: const ValueKey('email_login'),
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
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
                      key: const ValueKey('email_register'),
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
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

  void onSubmit() {
    if (isLoginSelected) {
      print("Login with Email: ${emailController.text}");
      print("Password: ${passwordController.text}");
    } else {
      print("Register with Name: ${nameController.text}");
      print("Email: ${emailController.text}");
      print("Password: ${passwordController.text}");
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isLoginSelected ? 'Login pressed' : 'Register pressed'),
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
          constraints: const BoxConstraints(
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
                  onPressed: onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
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
