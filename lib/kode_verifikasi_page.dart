import 'package:flutter/material.dart';
import 'lupa_sandi_page.dart';
import 'masukan_sandi_baru_page.dart';

class KodeVerifikasiPage extends StatelessWidget {
  const KodeVerifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Teks "Kode Verifikasi"
          const Positioned(
            top: 44,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Kode Verifikasi',
                style: TextStyle(
                  fontFamily: 'PoppinsSemiBold',
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // Teks deskripsi OTP
          const Positioned(
            top: 98,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Kami telah mengirimkan kode OTP ke xxx@gmail.com\nuntuk proses verifikasi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PoppinsSemiBold',
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ),
          ),

          // 4 Kotak kode verifikasi
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  width: 59,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF888888),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                );
              }),
            ),
          ),

          // Tombol "Lanjut" (navigasi ke masukan_sandi_baru_page.dart)
          Positioned(
            top: 520,
            left: (screenWidth - 316) / 2,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MasukanSandiBaruPage(),
                  ),
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

          // Teks "Kembali" (navigasi ke lupa_sandi_page.dart)
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
                      builder: (context) => const LupaSandiPage(),
                    ),
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
