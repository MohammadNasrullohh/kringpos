import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ImagePickerCropperPage extends StatefulWidget {
  const ImagePickerCropperPage({super.key});

  @override
  State<ImagePickerCropperPage> createState() => _ImagePickerCropperPageState();
}

class _ImagePickerCropperPageState extends State<ImagePickerCropperPage> {
  File? _imageFile;

  Future<void> _pickAndCropImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio16x9,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Gambar',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Gambar',
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _imageFile = File(croppedFile.path);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image Picker & Cropper")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _imageFile != null
              ? Image.file(_imageFile!, height: 250)
              : const Text("Belum ada gambar"),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.photo_library),
            label: const Text("Pilih dari Galeri"),
            onPressed: () => _pickAndCropImage(ImageSource.gallery),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text("Ambil dari Kamera"),
            onPressed: () => _pickAndCropImage(ImageSource.camera),
          ),
        ],
      ),
    );
  }
}
