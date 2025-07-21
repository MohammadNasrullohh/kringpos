import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorit_page.dart';
import 'register_page.dart';
import 'lupa_sandi_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _showError = false;

  final databaseRef = FirebaseDatabase.instance.ref("users");

  void loginUser() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi semua kolom!')),
      );
      return;
    }

    if (username == 'admin' && password == 'atmin') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', 'admin');
      await prefs.setString('role', 'admin');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login sebagai Admin')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FavoritPage()),
      );
      return;
    }

    final snapshot = await databaseRef.get();
    bool isAuthenticated = false;
    String role = 'user';

    if (snapshot.exists) {
      final data = snapshot.value as Map;
      data.forEach((key, value) {
        final dbUsername = value['username'] ?? '';
        final dbPassword = value['password'] ?? '';
        final userRole = value['role'] ?? 'user';

        if (username == dbUsername && password == dbPassword) {
          isAuthenticated = true;
          role = userRole;
        }
      });
    }

    if (isAuthenticated) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      await prefs.setString('role', role);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FavoritPage()),
      );
    } else {
      setState(() => _showError = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showError = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Image.asset('assets/logo.png', width: 100, height: 100),

              const SizedBox(height: 30),
              Container(
                width: 232,
                height: 29,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 29,
                        decoration: BoxDecoration(
                          color: const Color(0xFF40AFFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'MASUK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            'DAFTAR',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'PoppinsMedium',
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Silakan masuk ke dalam akun kamu',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'PoppinsMedium',
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              buildInputField(
                controller: usernameController,
                hint: 'Username',
              ),
              buildInputField(
                controller: passwordController,
                hint: 'Password',
                obscureText: _obscurePassword,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LupaSandiPage()),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(top: 5, right: 5),
                    child: Text(
                      'Lupa sandi?',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'PoppinsMedium',
                        color: Color(0xFF4D9AD1),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                offset: _showError ? Offset.zero : const Offset(0, -0.3),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _showError ? 1.0 : 0.0,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 322),
                    height: 34,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0x99FF0000), // FF0000 dengan 60% opacity
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Username atau Kata sandi salah',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'PoppinsMedium',
                      ),
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: loginUser,
                child: Container(
                  height: 45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'MASUK',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'PoppinsSemiBold',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
  }) {
    return Container(
      height: 45,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF888888), width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'PoppinsMedium',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 12,
                  fontFamily: 'PoppinsMedium',
                ),
              ),
            ),
          ),
          if (hint == 'Password')
            IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
        ],
      ),
    );
  }
}
