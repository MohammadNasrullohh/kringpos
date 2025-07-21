import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';

class UploadService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Ganti dengan Cloudinary preset & cloud name kamu
  final String cloudName = "CLOUD_NAME_KAMU";
  final String uploadPreset = "UPLOAD_PRESET_KAMU";

  Future<File?> pickAndCropImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 85);

    if (pickedFile == null) return null;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatioPresets: [CropAspectRatioPreset.square],
      compressQuality: 80,
      uiSettings: [
        AndroidUiSettings(toolbarTitle: 'Crop Foto'),
        IOSUiSettings(title: 'Crop Foto')
      ],
    );

    if (croppedFile == null) return null;

    return File(croppedFile.path);
  }

  Future<String?> uploadToCloudinary(File imageFile) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final resJson = json.decode(resStr);
      return resJson['secure_url'];
    } else {
      return null;
    }
  }

  Future<void> saveImageUrlToFirebase(String username, String imageUrl) async {
    await _database.ref('users/$username').update({
      'profile_image': imageUrl,
    });
  }

  // Fungsi utuh: pick > crop > upload > simpan URL
  Future<void> pickCropUploadSave(BuildContext context, ImageSource source, String username) async {
    final imageFile = await pickAndCropImage(source);
    if (imageFile == null) return;

    final imageUrl = await uploadToCloudinary(imageFile);
    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal upload ke Cloudinary")));
      return;
    }

    await saveImageUrlToFirebase(username, imageUrl);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil upload ke Cloudinary dan Firebase")));
  }
}
