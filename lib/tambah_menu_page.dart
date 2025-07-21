import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'favorit_page.dart';
import 'sukses_tambah.dart';

class TambahMenuPage extends StatefulWidget {
  const TambahMenuPage({super.key});

  @override
  State<TambahMenuPage> createState() => _TambahMenuPageState();
}

class _TambahMenuPageState extends State<TambahMenuPage> {
  final namaController = TextEditingController();
  String kategori = 'Makanan';
  final stokController = TextEditingController();
  final hargaController = TextEditingController();
  final diskonController = TextEditingController();

  File? _selectedImage;
  final picker = ImagePicker();
  final databaseRef = FirebaseDatabase.instance.ref().child('menu');

  Future<File?> _pickImage() async {
    final pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () async {
                final file = await picker.pickImage(source: ImageSource.camera);
                if (mounted) Navigator.pop(context, file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () async {
                final file = await picker.pickImage(source: ImageSource.gallery);
                if (mounted) Navigator.pop(context, file);
              },
            ),
          ],
        ),
      ),
    );
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<String?> _uploadImage(File imageFile) async {
    const cloudName = 'dpgbstlfj';
    const uploadPreset = 'kringpos';

    final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath("file", imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final res = await http.Response.fromStream(response);
      return json.decode(res.body)['secure_url'];
    }
    return null;
  }

  Future<void> _simpanData() async {
    if (namaController.text.isEmpty ||
        kategori.isEmpty ||
        stokController.text.isEmpty ||
        hargaController.text.isEmpty ||
        diskonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field harus diisi")),
      );
      return;
    }

    String imageUrl = '';
    if (_selectedImage != null) {
      final uploadedUrl = await _uploadImage(_selectedImage!);
      if (uploadedUrl != null) {
        imageUrl = uploadedUrl;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal upload gambar ke Cloudinary")),
        );
        return;
      }
    }

    final data = {
      "nama_menu": namaController.text,
      "kategori": kategori,
      "stok": int.parse(stokController.text),
      "harga_jual": int.parse(hargaController.text),
      "diskon": int.parse(diskonController.text),
      "gambar_url": imageUrl,
    };

    try {
      await databaseRef.push().set(data);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SuksesTambahPage(
            nama: namaController.text,
            kategori: kategori,
            stok: int.parse(stokController.text),
            harga: int.parse(hargaController.text),
            diskon: int.parse(diskonController.text),
            fotoPath: imageUrl,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Stack(
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Tambah Menu',
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
                    child: Image.asset('assets/right.png', width: 25, height: 25),
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
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: () async {
                          final image = await _pickImage();
                          if (image != null) {
                            setState(() {
                              _selectedImage = image;
                            });
                          }
                        },
                        child: Center(
                          child: _selectedImage != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              width: 117,
                              height: 112,
                              fit: BoxFit.cover,
                            ),
                          )
                              : SizedBox(
                            width: 117,
                            height: 112,
                            child: Stack(
                              children: [
                                CustomPaint(
                                  size: const Size(117, 112),
                                  painter: DashedBorderPainter(),
                                ),
                                const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.upload,
                                          size: 24, color: Color(0xFF888888)),
                                      SizedBox(height: 6),
                                      Text(
                                        'Upload foto',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Poppins',
                                          color: Color(0xFF888888),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildInput('Nama Menu', namaController),
                            const SizedBox(height: 20),
                            _buildDropdownKategori(),
                            const SizedBox(height: 20),
                            _buildInput('Stok', stokController, isNumeric: true),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInput('Harga Jual', hargaController,
                                      isNumeric: true),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildInput('Diskon', diskonController,
                                      isNumeric: true),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: MediaQuery.of(context).size.width / 2 - 158,
                  child: SizedBox(
                    height: 45,
                    width: 316,
                    child: ElevatedButton(
                      onPressed: _simpanData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0095FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Tambah',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownKategori() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kategori', style: TextStyle(fontSize: 12, fontFamily: 'Poppins')),
        const SizedBox(height: 8),
        Container(
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x80000000), width: 0.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: kategori,
              isExpanded: true,
              style: const TextStyle(fontSize: 12, fontFamily: 'Poppins', color: Colors.black),
              onChanged: (value) => setState(() => kategori = value!),
              items: const [
                DropdownMenuItem(value: 'Makanan', child: Text('Makanan')),
                DropdownMenuItem(value: 'Minuman', child: Text('Minuman')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontFamily: 'Poppins')),
        const SizedBox(height: 8),
        Container(
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x80000000), width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: controller,
              keyboardType:
              isNumeric ? TextInputType.number : TextInputType.text,
              inputFormatters:
              isNumeric ? [FilteringTextInputFormatter.digitsOnly] : [],
              decoration: const InputDecoration(border: InputBorder.none),
              style: const TextStyle(fontSize: 12, fontFamily: 'Poppins'),
            ),
          ),
        ),
      ],
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    final paint = Paint()
      ..color = const Color(0xFF888888)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = ui.Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)));
    final dashedPath = _createDashedPath(path, dashWidth, dashSpace);
    canvas.drawPath(dashedPath, paint);
  }

  ui.Path _createDashedPath(ui.Path source, double dashWidth, double dashSpace) {
    final dest = ui.Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        distance += dashWidth + dashSpace;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
