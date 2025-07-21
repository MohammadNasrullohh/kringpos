
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'edit_menu.dart';

class DetailMenuPage extends StatefulWidget {
  final Map<String, dynamic> menuData;

  const DetailMenuPage({super.key, required this.menuData});

  @override
  State<DetailMenuPage> createState() => _DetailMenuPageState();
}

class _DetailMenuPageState extends State<DetailMenuPage> {
  bool showDropdown = false;
  bool isDeleting = false;

  final DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('menu');
  final DatabaseReference transaksiRef = FirebaseDatabase.instance.ref().child('transaksi');

  String formatRupiah(dynamic value) {
    if (value == null || value == "") return 'Rp 0';
    num number;

    if (value is String) {
      number = num.tryParse(value) ?? 0;
    } else if (value is int || value is double) {
      number = value;
    } else {
      return 'Rp 0';
    }

    final formatted = number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
    );
    return 'Rp $formatted';
  }

  Future<void> _deleteMenu() async {
    final key = widget.menuData['key'];
    if (key == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Key menu tidak ditemukan')),
      );
      return;
    }

    setState(() {
      isDeleting = true;
    });

    try {
      await dbRef.child(key).remove();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu berhasil dihapus')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal hapus menu: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isDeleting = false;
          showDropdown = false;
        });
      }
    }
  }

  Future<void> orderPesanan() async {
    final String idTransaksi = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().toString();

    final dataTransaksi = {
      "id_transaksi": idTransaksi,
      "jumlah_bayar": "",
      "kembalian": "",
      "metode_pembayaran": "Tunai",
      "nama_kasir": "Budi", // Ganti sesuai kasir login
      "no_meja": "1",
      "status": "Dine In",
      "waktu_pembayaran": now,
      "menu_dipesan": [
        {
          "nama_menu": widget.menuData['nama_menu'] ?? '-',
          "jumlah_menu": 1,
        }
      ]
    };

    try {
      await transaksiRef.push().set(dataTransaksi);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil disimpan')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan pesanan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String nama = widget.menuData['nama_menu'] ?? '-';
    final String kategori = widget.menuData['kategori'] ?? '-';
    final String stok = widget.menuData['stok']?.toString() ?? '-';
    final dynamic hargaRaw = widget.menuData['harga_jual'] ?? widget.menuData['harga'];
    final int harga = int.tryParse(hargaRaw?.toString() ?? '') ?? 0;
    final String diskon = widget.menuData['diskon']?.toString() ?? '-';
    final String gambar = widget.menuData['gambar_url'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Image.asset(
                            'assets/right.png',
                            width: 25,
                            height: 25,
                          ),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Detail Menu',
                          style: TextStyle(
                            fontFamily: 'PoppinsMedium',
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 0.5, color: const Color(0xFF9B9797)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 15,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      infoItem('Nama Menu', nama, isTitle: true),
                                      infoItem('Kategori', kategori),
                                      infoItem('Stok', '$stok Porsi'),
                                      infoItem('Harga Jual', formatRupiah(harga)),
                                      infoItem('Diskon', diskon == '0' ? '-' : '$diskon%'),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 15),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: gambar.isNotEmpty
                                      ? Image.network(
                                    gambar,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  )
                                      : Container(
                                    width: 120,
                                    height: 120,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() => showDropdown = true),
                                  child: actionButton(
                                    'Hapus',
                                    color: Colors.white,
                                    borderColor: const Color(0xFFFF0000),
                                    textColor: const Color(0xFFFF0000),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditMenuPage(menuData: widget.menuData),
                                      ),
                                    );
                                  },
                                  child: actionButton(
                                    'Edit',
                                    color: const Color(0xFF0095FF),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                GestureDetector(
                                  onTap: orderPesanan,
                                  child: actionButton(
                                    'Order Pesanan',
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Popup konfirmasi hapus
          if (showDropdown)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => showDropdown = false),
                child: Container(
                  color: Colors.black.withAlpha(77),
                  child: Center(
                    child: Container(
                      width: 329,
                      height: 173,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(77),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Yakin Akan dihapus?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'PoppinsMedium',
                                fontSize: 20,
                                color: Colors.black87,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() => showDropdown = false),
                                  child: Container(
                                    width: 120,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey),
                                      color: Colors.white,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Tidak',
                                        style: TextStyle(
                                          fontFamily: 'PoppinsMedium',
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: isDeleting ? null : _deleteMenu,
                                  child: Container(
                                    width: 120,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: isDeleting
                                          ? Colors.red.shade300
                                          : const Color(0xFFFF0000),
                                    ),
                                    child: Center(
                                      child: isDeleting
                                          ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                          : const Text(
                                        'Ya',
                                        style: TextStyle(
                                          fontFamily: 'PoppinsMedium',
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget infoItem(String label, String value, {bool isTitle = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: isTitle ? 'PoppinsMedium' : 'Poppins',
              fontSize: isTitle ? 20 : 13,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget actionButton(String label,
      {required Color color, Color? borderColor, Color? textColor}) {
    return Container(
      width: 121,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: borderColor == null ? color : Colors.white,
        border: borderColor != null ? Border.all(color: borderColor, width: 1) : null,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'PoppinsSemiBold',
            fontSize: 16,
            color: textColor ?? (borderColor != null ? borderColor : Colors.white),
          ),
        ),
      ),
    );
  }
}

