import 'package:flutter/material.dart';
import 'register_page.dart'; // Ganti path jika perlu
import 'login_page.dart'; // Ganti path jika perlu

class KategoriUser extends StatelessWidget {
  const KategoriUser({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double logoSmallLeft = screenWidth * (26 / 360);
    final double logoSmallTop = screenHeight * (122 / 800);
    final double logoSmallWidth = screenWidth * (76 / 360);
    final double logoSmallHeight = screenHeight * (63 / 800);

    final double logoTop = screenHeight * (210 / 800);
    final double logoWidth = screenWidth * (342 / 360);
    final double logoHeight = logoWidth * (277.76 / 342);
    final double logoLeft = (screenWidth - logoWidth) / 2;

    final double buttonWidth = screenWidth * (322 / 360);
    final double buttonHeight = 40; // tetap 40 sesuai instruksi
    final double buttonLeft = (screenWidth - buttonWidth) / 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Logo kecil
          Positioned(
            left: logoSmallLeft,
            top: logoSmallTop,
            child: Image.asset(
              'assets/logo.png',
              width: logoSmallWidth,
              height: logoSmallHeight,
              fit: BoxFit.contain,
            ),
          ),

          // Logo besar di tengah
          Positioned(
            left: logoLeft,
            top: logoTop,
            child: Image.asset(
              'assets/logobesar.png',
              width: logoWidth,
              height: logoHeight,
              fit: BoxFit.contain,
            ),
          ),

          // Teks "Selamat Datang!"
          Positioned(
            left: screenWidth * (24 / 360),
            top: 60,
            child: const Text(
              'Selamat Datang!',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF40AFFF),
              ),
            ),
          ),

          // Teks "Daftar Sebagai"
          Positioned(
            top: 465,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Daftar Sebagai',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // Tombol Kasir
          Positioned(
            top: 500,
            left: buttonLeft,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: Container(
                width: buttonWidth,
                height: buttonHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF0095FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'KASIR',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Tombol Owner
          Positioned(
            top: 550,
            left: buttonLeft,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: Container(
                width: buttonWidth,
                height: buttonHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF0095FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'OWNER',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.white,
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
