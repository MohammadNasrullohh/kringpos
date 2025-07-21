import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;

class CropResizePage extends StatefulWidget {
  final File imageFile;

  const CropResizePage({super.key, required this.imageFile});

  @override
  State<CropResizePage> createState() => _CropResizePageState();
}

class _CropResizePageState extends State<CropResizePage> {
  File? _croppedImage;

  @override
  void initState() {
    super.initState();
    _cropInitialImage();
  }

  Future<void> _cropInitialImage() async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: widget.imageFile.path,
      aspectRatioPresets: [CropAspectRatioPreset.square],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Potong Gambar',
          toolbarColor: Colors.blueAccent,
          toolbarWidgetColor: Colors.white,
          backgroundColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Potong Gambar'),
      ],
    );

    if (cropped != null) {
      final resized = await _resizeImage(File(cropped.path), 300, 300);
      setState(() {
        _croppedImage = resized;
      });
    } else {
      Navigator.pop(context); // Batal crop, kembali
    }
  }

  Future<File> _resizeImage(File file, int width, int height) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return file;

    final resized = img.copyResize(decoded, width: width, height: height);
    final resizedBytes = img.encodeJpg(resized);
    final newPath = '${file.parent.path}/resized_${file.uri.pathSegments.last}';

    return File(newPath)..writeAsBytesSync(Uint8List.fromList(resizedBytes));
  }

  void _confirmAndReturn() {
    if (_croppedImage != null) {
      Navigator.pop(context, _croppedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Foto"),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (_croppedImage != null)
            IconButton(
              onPressed: _confirmAndReturn,
              icon: const Icon(Icons.check, color: Colors.white),
              tooltip: 'Simpan',
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              _croppedImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_croppedImage!, width: 200, height: 200, fit: BoxFit.cover),
              )
                  : const CircularProgressIndicator(),

              const SizedBox(height: 30),

              OutlinedButton.icon(
                icon: const Icon(Icons.replay, color: Colors.blue),
                label: const Text("Ulangi", style: TextStyle(color: Colors.blue)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: _cropInitialImage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
