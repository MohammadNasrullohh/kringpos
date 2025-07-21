import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class LupaSandiPage extends StatefulWidget {
  const LupaSandiPage({super.key});

  @override
  State<LupaSandiPage> createState() => _LupaSandiPageState();
}

class _LupaSandiPageState extends State<LupaSandiPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final inputBoxWidth = 322.0;
    final inputBoxHeight = 40.0;
    final inputLeft = (screenWidth - inputBoxWidth) / 2;
    final buttonWidth = 316.0;
    final buttonHeight = 47.0;
    final buttonLeft = (screenWidth - buttonWidth) / 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Judul
          const Positioned(
            top: 44,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Lupa Kata Sandi',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'PoppinsSemiBold',
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // Deskripsi
          const Positioned(
            top: 98,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Masukkan Email anda untuk membuat\nkata sandi baru',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'PoppinsMedium',
                  color: Color(0xFF9E9E9E),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Label Email
          const Positioned(
            top: 162,
            left: 20,
            child: Text(
              'Email',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'PoppinsMedium',
                color: Colors.black,
              ),
            ),
          ),

          // Kotak Input
          Positioned(
            top: 190,
            left: inputLeft,
            child: Container(
              width: inputBoxWidth,
              height: inputBoxHeight,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.black,
                  width: 0.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Masukkan email anda',
                  ),
                ),
              ),
            ),
          ),

          // Tombol Lanjut
          Positioned(
            top: 520,
            left: buttonLeft,
            child: GestureDetector(
              onTap: () async {
                final email = _emailController.text.trim();
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email tidak boleh kosong')),
                  );
                  return;
                }

                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link reset telah dikirim ke email')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Terjadi kesalahan: $e')),
                  );
                }
              },
              child: Container(
                width: buttonWidth,
                height: buttonHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF0095FF),
                  borderRadius: BorderRadius.circular(25),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Lanjut',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'PoppinsSemiBold',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Teks Kembali
          Positioned(
            top: 580,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text(
                  'Kembali',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'PoppinsSemiBold',
                    color: Color(0xFF0095FF),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
