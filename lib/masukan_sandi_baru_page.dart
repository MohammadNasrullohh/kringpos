import 'package:flutter/material.dart';
import 'kode_verifikasi_page.dart';
import 'login_page.dart';

class MasukanSandiBaruPage extends StatelessWidget {
  const MasukanSandiBaruPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Teks "Lupa Kata Sandi"
          const Positioned(
            top: 44,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Lupa Kata Sandi',
                style: TextStyle(
                  fontFamily: 'PoppinsSemiBold',
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // Teks "Buat kata sandi baru"
          const Positioned(
            top: 107,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Buat kata sandi baru',
                style: TextStyle(
                  fontFamily: 'PoppinsMedium',
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ),
          ),

          // Teks "Kata Sandi"
          const Positioned(
            top: 162,
            left: 20,
            child: Text(
              'Kata Sandi',
              style: TextStyle(
                fontFamily: 'PoppinsMedium',
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),

          // Rectangle 1
          Positioned(
            top: 190,
            left: (screenWidth - 322) / 2,
            child: Container(
              width: 322,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFF888888),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          // Teks "Konfirmasi"
          const Positioned(
            top: 255,
            left: 20,
            child: Text(
              'Konfirmasi',
              style: TextStyle(
                fontFamily: 'PoppinsMedium',
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),

          // Rectangle 2
          Positioned(
            top: 283,
            left: (screenWidth - 322) / 2,
            child: Container(
              width: 322,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Color(0xFF888888),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          // Tombol "Lanjut" ke LoginPage
          Positioned(
            top: 520,
            left: (screenWidth - 316) / 2,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: Container(
                width: 316,
                height: 47,
                decoration: BoxDecoration(
                  color: const Color(0xFF0095FF),
                  borderRadius: BorderRadius.circular(25),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Lanjut',
                  style: TextStyle(
                    fontFamily: 'PoppinsSemiBold',
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Teks "Kembali" ke KodeVerifikasiPage
          Positioned(
            top: 580,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const KodeVerifikasiPage()),
                  );
                },
                child: const Text(
                  'Kembali',
                  style: TextStyle(
                    fontFamily: 'PoppinsSemiBold',
                    fontSize: 18,
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
