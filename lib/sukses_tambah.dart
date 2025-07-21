import 'dart:async';
import 'package:flutter/material.dart';
import 'favorit_page.dart';

class SuksesTambahPage extends StatefulWidget {
  final String nama;
  final String kategori;
  final int stok;
  final int harga;
  final int diskon;
  final String fotoPath;

  const SuksesTambahPage({
    super.key,
    required this.nama,
    required this.kategori,
    required this.stok,
    required this.harga,
    required this.diskon,
    required this.fotoPath,
  });

  @override
  State<SuksesTambahPage> createState() => _SuksesTambahPageState();
}

class _SuksesTambahPageState extends State<SuksesTambahPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();

    // Perpanjang durasi jadi 6 detik sebelum navigasi
    _timer = Timer(const Duration(seconds: 6), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FavoritPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String formatRupiah(int amount) {
    return 'Rp. ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _animation,
        child: Stack(
          children: [
            // Gambar sukses
            Positioned(
              top: 128,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/sukses.png',
                  width: 100,
                  height: 100,
                ),
              ),
            ),

            // Teks sukses
            const Positioned(
              top: 252,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Menu berhasil ditambahkan!',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Preview Rectangle
            Positioned(
              top: 324,
              left: (screenWidth - 339) / 2,
              child: Container(
                width: 339,
                height: 151,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(
                    color: const Color(0x35000000),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // Foto menu
                    Positioned(
                      top: 22,
                      left: 20,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.network(
                          widget.fotoPath,
                          width: 76,
                          height: 73,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 76,
                              height: 73,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 24),
                            );
                          },
                        ),
                      ),
                    ),

                    // Nama menu
                    Positioned(
                      top: 22,
                      left: 115,
                      child: Text(
                        widget.nama,
                        style: const TextStyle(
                          fontFamily: 'PoppinsMedium',
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    // Kategori
                    Positioned(
                      top: 50,
                      left: 115,
                      child: Text(
                        'Kategori: ${widget.kategori}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    // Stok
                    Positioned(
                      top: 70,
                      left: 115,
                      child: Text(
                        'Stok: ${widget.stok}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    // Harga
                    Positioned(
                      top: 90,
                      left: 115,
                      child: Text(
                        'Harga Jual: ${formatRupiah(widget.harga)}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    // Diskon
                    Positioned(
                      top: 110,
                      left: 115,
                      child: Text(
                        'Diskon: ${widget.diskon}%',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
