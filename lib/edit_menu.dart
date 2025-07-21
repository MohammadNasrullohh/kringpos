import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'favorit_page.dart';

class EditMenuPage extends StatefulWidget {
  final Map<String, dynamic> menuData;

  const EditMenuPage({super.key, required this.menuData});

  @override
  State<EditMenuPage> createState() => _EditMenuPageState();
}

class _EditMenuPageState extends State<EditMenuPage> {
  late TextEditingController namaController;
  late TextEditingController stokController;
  late TextEditingController hargaController;
  late TextEditingController diskonController;
  late String kategori;

  File? _selectedImage;
  final picker = ImagePicker();
  final databaseRef = FirebaseDatabase.instance.ref().child('menu');

  @override
  void initState() {
    super.initState();
    final data = widget.menuData;
    namaController = TextEditingController(text: data['nama_menu'] ?? '');
    kategori = data['kategori'] ?? 'Makanan';
    stokController = TextEditingController(text: data['stok']?.toString() ?? '');
    hargaController = TextEditingController(text: data['harga_jual']?.toString() ?? '');
    diskonController = TextEditingController(text: data['diskon']?.toString() ?? '');
  }

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

  Future<void> _simpanData() async {
    final updatedData = {
      "nama_menu": namaController.text,
      "kategori": kategori,
      "stok": int.tryParse(stokController.text) ?? 0,
      "harga_jual": int.tryParse(hargaController.text) ?? 0,
      "diskon": int.tryParse(diskonController.text) ?? 0,
      "gambar_url": _selectedImage != null ? await _uploadImage(_selectedImage!) : widget.menuData['gambar_url'],
    };

    final key = widget.menuData['key'];
    if (key != null) {
      await databaseRef.child(key).update(updatedData);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FavoritPage()));
    }
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

  @override
  Widget build(BuildContext context) {
    final String initialImageUrl = widget.menuData['gambar_url'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Edit Menu', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset('assets/right.png', width: 25, height: 25),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(width: double.infinity, height: 0.5, color: const Color(0xFF9B9797)),
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
                        child: Image.file(_selectedImage!, width: 117, height: 112, fit: BoxFit.cover),
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(initialImageUrl, width: 117, height: 112, fit: BoxFit.cover),
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
                            Expanded(child: _buildInput('Harga Jual', hargaController, isNumeric: true)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildInput('Diskon', diskonController, isNumeric: true)),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
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
                  'Simpan',
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

  Widget _buildInput(String label, TextEditingController controller, {bool isNumeric = false}) {
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
              keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
              inputFormatters: isNumeric ? [FilteringTextInputFormatter.digitsOnly] : [],
              decoration: const InputDecoration(border: InputBorder.none),
              style: const TextStyle(fontSize: 12, fontFamily: 'Poppins'),
            ),
          ),
        ),
      ],
    );
  }
}
