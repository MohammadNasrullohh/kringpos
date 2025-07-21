import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'favorit_page.dart';
import 'tambah_menu_page.dart';
import 'detail_menu.dart';

class ManajemenMenuPage extends StatefulWidget {
  const ManajemenMenuPage({super.key});

  @override
  State<ManajemenMenuPage> createState() => _ManajemenMenuPageState();
}

class _ManajemenMenuPageState extends State<ManajemenMenuPage> {
  final DatabaseReference _menuRef = FirebaseDatabase.instance.ref().child('menu');

  String formatRupiah(dynamic value) {
    try {
      if (value == null) return 'Rp 0';
      num number;

      if (value is String) {
        number = num.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      } else if (value is int || value is double) {
        number = value;
      } else {
        return 'Rp 0';
      }

      String str = number.toStringAsFixed(0);
      final result = str.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
      );
      return 'Rp $result';
    } catch (e) {
      return 'Rp 0';
    }
  }

  Future<bool> isNamaMenuExists(String namaMenu) async {
    final snapshot = await _menuRef.get();
    if (snapshot.exists && snapshot.value is Map) {
      final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
      return data.values.any((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return (map['nama_menu']?.toString().toLowerCase().trim() ?? '') ==
            namaMenu.toLowerCase().trim();
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Stack(
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Manajemen Menu',
                      style: TextStyle(
                        fontFamily: 'PoppinsMedium',
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const FavoritPage()),
                        );
                      },
                      child: Image.asset(
                        'assets/right.png',
                        width: 25,
                        height: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 0.5,
              width: double.infinity,
              color: const Color(0xFF9B9797),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Daftar Menu',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF0095FF),
                    ),
                  ),
                  Text(
                    'Stok',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF0095FF),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: _menuRef.onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                  }

                  final rawData = snapshot.data?.snapshot.value;
                  if (rawData == null || rawData is! Map) {
                    return const Center(child: Text('Tidak ada data menu.'));
                  }

                  final dataMap = Map<dynamic, dynamic>.from(rawData);
                  final filteredData = dataMap.entries
                      .where((entry) => entry.key.toString() != '1')
                      .map((entry) {
                    final menu = Map<String, dynamic>.from(entry.value as Map);
                    menu['key'] = entry.key;
                    return menu;
                  })
                      .where((menu) =>
                  menu['nama_menu'] != null &&
                      menu['nama_menu'].toString().trim().isNotEmpty &&
                      menu['kategori'] != null &&
                      menu['kategori'].toString().trim().isNotEmpty)
                      .toList();

                  final makananList = filteredData
                      .where((item) =>
                  (item['kategori']?.toString().toLowerCase() ?? '') == 'makanan')
                      .toList();
                  final minumanList = filteredData
                      .where((item) =>
                  (item['kategori']?.toString().toLowerCase() ?? '') == 'minuman')
                      .toList();

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    children: [
                      if (makananList.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Text(
                            'Makanan',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ),
                      ...makananList.map((menu) => _buildMenuTile(menu)),
                      if (minumanList.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 15, bottom: 5),
                          child: Text(
                            'Minuman',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ),
                      ...minumanList.map((menu) => _buildMenuTile(menu)),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TambahMenuPage()),
                  );
                },
                child: const SizedBox(
                  width: 316,
                  height: 47,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFF0095FF),
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    child: Center(
                      child: Text(
                        'Tambah Menu',
                        style: TextStyle(
                          fontFamily: 'PoppinsSemiBold',
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(Map<String, dynamic> menu) {
    final imageUrl = menu['gambar_url'] ?? '';
    final formattedHarga = formatRupiah(menu['harga_jual']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          splashColor: const Color(0xFF0095FF).withOpacity(0.3),
          highlightColor: const Color(0xFF0095FF).withOpacity(0.15),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailMenuPage(menuData: menu)),
            );
          },
          onLongPress: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Hapus Menu"),
                content: Text("Apakah kamu yakin ingin menghapus \"${menu['nama_menu']}\"?"),
                actions: [
                  TextButton(
                    child: const Text("Batal"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                    onPressed: () async {
                      if (menu['key'] != null) {
                        try {
                          await _menuRef.child(menu['key']).remove();
                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${menu['nama_menu']} berhasil dihapus.')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal menghapus: $e')),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white, width: 1.2),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                )
                    : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
              title: Text(
                menu['nama_menu'] ?? '-',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              subtitle: Text(
                formattedHarga,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              trailing: Text(
                menu['stok']?.toString() ?? '0',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
