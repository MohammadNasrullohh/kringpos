import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final databaseRef = FirebaseDatabase.instance.ref("users");

  bool _ingatSaya = false;
  bool _obscurePassword = true;

  bool _namaKosong = false;
  bool _emailKosong = false;
  bool _passwordKosong = false;

  Timer? _timerNama, _timerEmail, _timerPassword;

  @override
  void initState() {
    super.initState();
    loadIngatSaya();
    namaController.addListener(() {
      if (_namaKosong && namaController.text.isNotEmpty) {
        setState(() => _namaKosong = false);
      }
    });
    emailController.addListener(() {
      if (_emailKosong && emailController.text.isNotEmpty) {
        setState(() => _emailKosong = false);
      }
    });
    passwordController.addListener(() {
      if (_passwordKosong && passwordController.text.isNotEmpty) {
        setState(() => _passwordKosong = false);
      }
    });
  }

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _timerNama?.cancel();
    _timerEmail?.cancel();
    _timerPassword?.cancel();
    super.dispose();
  }

  Future<void> loadIngatSaya() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ingatSaya = prefs.getBool('ingat_saya') ?? false;
    });
  }

  Future<void> saveIngatSaya(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ingat_saya', value);
  }

  void simpanDataKeFirebase() {
    setState(() {
      _namaKosong = namaController.text.isEmpty;
      _emailKosong = emailController.text.isEmpty;
      _passwordKosong = passwordController.text.isEmpty;

      if (_namaKosong) {
        _timerNama?.cancel();
        _timerNama = Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _namaKosong = false);
        });
      }
      if (_emailKosong) {
        _timerEmail?.cancel();
        _timerEmail = Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _emailKosong = false);
        });
      }
      if (_passwordKosong) {
        _timerPassword?.cancel();
        _timerPassword = Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _passwordKosong = false);
        });
      }
    });

    if (_namaKosong || _emailKosong || _passwordKosong) return;

    final userId = DateTime.now().millisecondsSinceEpoch.toString();

    databaseRef.child(userId).set({
      'username': namaController.text,
      'email': emailController.text,
      'password': passwordController.text,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun berhasil didaftarkan')),
      );
      namaController.clear();
      emailController.clear();
      passwordController.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $error')),
      );
    });
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
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            'MASUK',
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
                    Expanded(
                      child: Container(
                        height: 29,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF40AFFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'DAFTAR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Poppins',
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
                  'Silakan daftarkan akun kamu',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'PoppinsMedium',
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              buildInputField(
                controller: namaController,
                hint: 'Masukkan Username',
                isError: _namaKosong,
                errorText: 'Nama tidak boleh kosong',
              ),
              buildInputField(
                controller: emailController,
                hint: 'Masukkan Email',
                isError: _emailKosong,
                errorText: 'Email tidak boleh kosong',
                keyboardType: TextInputType.emailAddress,
              ),
              buildInputField(
                controller: passwordController,
                hint: 'Kata Sandi',
                isError: _passwordKosong,
                errorText: 'Password tidak boleh kosong',
                obscure: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 10),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() => _ingatSaya = !_ingatSaya);
                      saveIngatSaya(_ingatSaya);
                    },
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _ingatSaya ? const Color(0xFF888888) : Colors.transparent,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: const Color(0xFF888888), width: 1),
                      ),
                      child: _ingatSaya
                          ? const Center(child: Icon(Icons.check, size: 10, color: Colors.white))
                          : null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Ingat Saya',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'PoppinsMedium',
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              GestureDetector(
                onTap: simpanDataKeFirebase,
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'DAFTAR',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'PoppinsSemiBold',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    bool isError = false,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isError ? const Color(0xFFFF0000) : const Color(0xFF888888),
              width: isError ? 1.2 : 0.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'PoppinsMedium',
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'PoppinsMedium',
                      color: Color(0xFF888888),
                    ),
                  ),
                ),
              ),
              if (suffixIcon != null)
                suffixIcon
              else if (isError)
                const Icon(Icons.error_outline, size: 18, color: Color(0xFFFF0000)),
            ],
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation), child: FadeTransition(opacity: animation, child: child)),
          child: isError
              ? Padding(
            key: ValueKey(errorText),
            padding: const EdgeInsets.only(top: 4, left: 8),
            child: Text(
              errorText ?? '',
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'PoppinsMedium',
                color: Color(0xFFFF0000),
              ),
            ),
          )
              : const SizedBox(height: 14),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}
